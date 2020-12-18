# Use:
#     awk -f main.awk < input.txt
# Runtime version:
#     awk --version
#     GNU Awk 5.0.1, API: 2.0 (GNU MPFR 4.1.0, GNU MP 6.2.0)


# Part 1 grammar:
#     part1_root := part1_expression (('+' | '*') part1_expression)*
#     part1_expression := part1_paren_expression | part1_number
#     part1_paren_expression := '(' part1_root ')'


function part1(expression) {
    state["position"] = 1
    return part1_evaluate_root(expression, state)
}

function consumeChar(state) {
    state["position"] = state["position"] + 1;
}
function consumeString(state, str) {
    state["position"] = state["position"] + length(str);
}
function current(value, state) {
    return substr(value, state["position"], 1)
}

# Local variables don't exist in AWK
# We use this workaround: https://stackoverflow.com/a/5209695
function part1_evaluate_root(value, state, res) {

    res = part1_evaluate_expression(value, state)

    while (state["position"] < length(value)) {

        first_char = current(value, state);

        if (first_char == ")")
            break;

        switch (first_char) {
            case "+":
                consumeChar(state);
                res += part1_evaluate_expression(value, state)
                break;
            case "*":
                consumeChar(state);
                res *= part1_evaluate_expression(value, state)
                break;
        }
    }

    return res
}

function part1_evaluate_expression(value, state) {
    if (current(value, state) == "(")
        return part1_evaluate_paren_expression(value, state);

    number_start = substr(value, state["position"]);
    number = int(number_start);

    consumeString(state, number);
    return number;
}

function part1_evaluate_paren_expression(value, state, res) {
    consumeChar(state); # consume '('
    res = part1_evaluate_root(value, state)
    consumeChar(state); # consume ')'
    return res;
}

{
    gsub(/ /, "", $0);
    sum += part1($0);
}

END {
    print "Sum of all terms; Part 1: " sum;
}
