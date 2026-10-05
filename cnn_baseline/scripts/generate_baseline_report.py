from pathlib import Path
import datetime


root = Path("reports")


def count_lines(filename):

    path = root / filename

    if not path.exists():

        return "NOT FOUND"

    with open(path) as f:

        return sum(
            1 for line in f
            if line.strip()
        )


report = []

report.append(
    "=============================================="
)

report.append(
    " HEALTHY CNN FPGA BASELINE"
)

report.append(
    "=============================================="
)

report.append("")

report.append(
    "Generated: " +
    str(datetime.datetime.now())
)

report.append("")

report.append("MODEL")

report.append(
    "Input              : 28x28 grayscale"
)

report.append(
    "Conv1              : 1 -> 8, 3x3"
)

report.append(
    "Pool1              : 2x2"
)

report.append(
    "Conv2              : 8 -> 16, 3x3"
)

report.append(
    "Pool2              : 2x2"
)

report.append(
    "FC                 : 784 -> 10"
)

report.append("")

report.append("VERIFICATION")

report.append(
    "Conv1 outputs      : " +
    str(count_lines("rtl_conv1_pe_results.txt"))
)

report.append(
    "Pool1 outputs      : " +
    str(count_lines("rtl_pool1_results.txt"))
)

report.append(
    "Conv2 outputs      : " +
    str(count_lines("rtl_conv2_results.txt"))
)

report.append(
    "Pool2 outputs      : " +
    str(count_lines("rtl_pool2_results.txt"))
)

report.append("")

report.append("EXPECTED")

report.append(
    "Conv1              : 6272"
)

report.append(
    "Pool1              : 1568"
)

report.append(
    "Conv2              : 3136"
)

report.append(
    "Pool2              : 784"
)

report.append(
    "FC                 : 10"
)

report.append("")

report.append("ARCHITECTURE")

report.append(
    "Healthy baseline only"
)

report.append(
    "Hardware Trojan     : NOT INJECTED"
)

report.append("")

report.append("PE operations")

report.append(
    "Conv1              : 3x3 MAC"
)

report.append(
    "Conv2              : 3x3 MAC"
)

report.append(
    "Pooling            : 2x2 MAX"
)

report.append(
    "FC                 : 784 MACs/class"
)

report.append("")

report.append(
    "=============================================="
)


output = root / "HEALTHY_BASELINE_FINAL.txt"

with open(output, "w") as f:

    f.write(
        "\n".join(report)
    )


print(
    "Generated:",
    output
)
