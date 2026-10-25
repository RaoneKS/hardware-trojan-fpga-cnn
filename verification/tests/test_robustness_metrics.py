"""Unit tests for verification/robustness_metrics.py."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "robustness_metrics.py"
spec = importlib.util.spec_from_file_location("robustness_metrics", SCRIPT)
metrics = importlib.util.module_from_spec(spec)
spec.loader.exec_module(metrics)

class WilsonIntervalTests(unittest.TestCase):
    def test_zero_of_ten_has_nonzero_upper_bound(self):
        lo, hi = metrics.wilson_interval(0, 10)
        self.assertEqual(lo, 0.0)
        self.assertGreater(hi, 0.0)
        self.assertLess(hi, 0.5)

    def test_all_successes_interval_is_not_point_one(self):
        lo, hi = metrics.wilson_interval(10, 10)
        self.assertLess(lo, 1.0)
        self.assertEqual(hi, 1.0)

    def test_empty_denominator_is_undefined(self):
        self.assertIsNone(metrics.wilson_interval(0, 0))

class ConfusionMetricTests(unittest.TestCase):
    def test_known_confusion_matrix(self):
        rows = [
            {"_present":True,"_detected":True,"_workload":"w0"},
            {"_present":True,"_detected":False,"_workload":"w1"},
            {"_present":False,"_detected":True,"_workload":"w2"},
            {"_present":False,"_detected":False,"_workload":"w3"},
        ]
        c = metrics.confusion(rows)
        self.assertEqual(c, {"tp":1,"tn":1,"fp":1,"fn":1})
        m = metrics.derived(c)
        for key in ("tpr","fpr","precision","f1"):
            self.assertAlmostEqual(m[key]["estimate"], 0.5)

    def test_perfect_canonical_counts_keep_uncertainty_visible(self):
        m = metrics.derived({"tp":50,"tn":10,"fp":0,"fn":0})
        self.assertEqual(m["tpr"]["estimate"], 1.0)
        self.assertEqual(m["fpr"]["estimate"], 0.0)
        self.assertEqual(m["precision"]["estimate"], 1.0)
        self.assertEqual(m["f1"]["estimate"], 1.0)
        self.assertGreater(m["fpr"]["ci95"][1], 0.0)
        self.assertLess(m["tpr"]["ci95"][0], 1.0)

    def test_cluster_bootstrap_reproducible(self):
        rows = []
        for i in range(4):
            rows += [
                {"_present":True,"_detected":True,"_workload":str(i)},
                {"_present":False,"_detected":False,"_workload":str(i)},
            ]
        a = metrics.bootstrap_f1_ci(rows, iterations=300, seed=7)
        b = metrics.bootstrap_f1_ci(rows, iterations=300, seed=7)
        self.assertEqual(a, b)
        self.assertIsNotNone(a)

    def test_csv_validation(self):
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / "runs.csv"
            path.write_text("workload_id,trojan_present,detected\nw0,1,1\nw0,0,0\n", encoding="utf-8")
            self.assertEqual(len(metrics.load_rows(path)), 2)
            path.write_text("workload_id,trojan_present,detected\nw0,maybe,1\n", encoding="utf-8")
            with self.assertRaises(ValueError):
                metrics.load_rows(path)

if __name__ == "__main__":
    unittest.main()
