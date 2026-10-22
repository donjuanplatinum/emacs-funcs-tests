from mpmath import mp
import subprocess
import argparse
import re
import random as rand
precises = [10,50,100,300]
x = [
    "1","2","10","100",
    "1.23235","2.3231325",
    "5.1231256","87.1231232"
]
x.extend(str(rand.uniform(0, 100)) for _ in range(5))
func_map = {
    "erf": (mp.erf,"calcFunc-erf",lambda x: (x,)),
    "psi": (mp.psi,"calcFunc-psi",lambda x: (0,x)),
}

parser = argparse.ArgumentParser()
parser.add_argument("function",help = "calc function. eg: calcFunc-erf")
args = parser.parse_args()

def calc_run(func,prec,x):
    func = func_map[func][1]
    stdout = subprocess.run(
    ["emacs",
     "-Q",
     "--batch",
     "-l",
     "./calc-test-complex-domain.el",
     "--",
     func,
     str(prec),
     *map(str,x)
     ],
    capture_output=True,
    text=True).stdout
    return stdout

def mpmath_run(func,prec,x):
    fn = func_map[func][0]
    args = func_map[func][2]
    mp.dps = prec
    return mp.nstr(fn(*args(mp.mpmathify(x))),n=prec)

def parse_calc_res(output):
    return re.findall(r'\[RESULT\].*?:\s*"([^"]+)"', output)
def diff_res(calc, mp, v):
    if calc != mp:
        return f"x = {v} is not right\n, calc:{calc}\n, mp:  {mp}"
    return f"{v} is ok"

for prec in precises:
    print("prec:",prec)
    func = args.function
    true_res = []
    calc_res = parse_calc_res(calc_run(func,prec,x))
    for v in x:
        true_res.append(mpmath_run(func,prec,v))
    for v,calc, true in zip(x,calc_res, true_res):
        print(diff_res(calc, true,v))

