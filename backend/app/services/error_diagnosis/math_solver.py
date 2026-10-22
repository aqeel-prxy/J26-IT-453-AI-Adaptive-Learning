"""
Mathematical Equation Solver & Step-by-Step Solution Generator
Owner: Ranathunga K.P.B.S (IT23322530)
Component 4: AI-Assisted Mathematical Solution Analysis, Error Diagnosis & Personalized Correction
Target: Sri Lankan G.C.E. Ordinary Level (Grade 10 & 11) Mathematics
"""

import re
from typing import Dict, Any, List, Optional, Tuple
import sympy as sp


class MathSolver:
    """Solves Grade 10-11 mathematical equations step-by-step and diagnoses student working."""

    UNSUPPORTED_KEYWORDS = [
        "integral", "derivative", "d/dx", "dy/dx", "matrix", "determinant",
        "vector", "limit", "log_", "ln(", "sin(", "cos(", "tan("
    ]

    @staticmethod
    def clean_math_text(text: str) -> str:
        """Standardize mathematical notation and characters."""
        if not text:
            return ""
        s = text.strip()
        s = s.replace("²", "^2").replace("³", "^3")
        s = s.replace("×", "*").replace("÷", "/")
        s = s.replace("−", "-").replace("–", "-")
        # Strip common instruction prefixes
        s = re.sub(r'^(?:solve(?:\s+for\s+[a-zA-Z])?|find\s+(?:the\s+value\s+of\s+)?[a-zA-Z]|factorise\s+and\s+solve|evaluate|calculate)\s*[:\-]?\s*', '', s, flags=re.I)
        return s.strip()

    @classmethod
    def solve_question(cls, question_text: str) -> Dict[str, Any]:
        """
        Validates, parses, and solves Grade 10 & 11 mathematical questions.
        Generates structured, pedagogical step-by-step derivations with explanations.
        Returns unsupported error if the question is invalid or beyond Grade 10/11 algebra.
        """
        if not question_text or not question_text.strip():
            return {
                "success": False,
                "supported": False,
                "question": question_text,
                "error_message": "Please enter a mathematical question."
            }

        cleaned = cls.clean_math_text(question_text)

        # Check for unsupported topics (Calculus, Trigonometry, Matrices)
        lower_q = cleaned.lower()
        for kw in cls.UNSUPPORTED_KEYWORDS:
            if kw in lower_q:
                return {
                    "success": False,
                    "supported": False,
                    "question": question_text,
                    "error_message": f"The topic containing '{kw}' is outside the Grade 10-11 syllabus supported by this solver. Please enter a linear or quadratic algebra equation."
                }

        # If question does not contain variable x, check if it's an arithmetic evaluation (e.g. 6 ÷ 2(1+2) =) or an unsupported non-variable equation (e.g. 5 + 3 = 8)
        if "x" not in lower_q:
            is_eval = False
            if "=" not in cleaned or cleaned.rstrip().endswith("="):
                is_eval = True
            elif "=" in cleaned:
                _, rhs_part = cleaned.split("=", 1)
                if rhs_part.strip() in ["", "?", "."]:
                    is_eval = True

            if is_eval and re.search(r'\d', cleaned):
                return cls._solve_arithmetic_expression(question_text, cleaned)
            else:
                return {
                    "success": False,
                    "supported": False,
                    "question": question_text,
                    "error_message": "The problem must contain variable 'x' to be solved (e.g. 2(x + 3) = 14 or 2x² + 5x - 3 = 0)."
                }

        # Ensure equality sign is present or implied
        if "=" not in cleaned:
            # Check if it's a polynomial expression to factorize/solve as = 0
            if "x" in cleaned:
                cleaned = f"{cleaned} = 0"
            else:
                return {
                    "success": False,
                    "supported": False,
                    "question": question_text,
                    "error_message": "Please enter an equation containing an equality sign '='."
                }

        lhs_str, rhs_str = cleaned.split("=", 1)

        # Try to parse into SymPy expression
        x = sp.Symbol('x')
        try:
            prep_lhs = cls._to_sympy_expr_str(lhs_str)
            prep_rhs = cls._to_sympy_expr_str(rhs_str)
            lhs_expr = sp.sympify(prep_lhs)
            rhs_expr = sp.sympify(prep_rhs)
            poly_expr = sp.expand(lhs_expr - rhs_expr)
            poly = sp.Poly(poly_expr, x)
        except Exception:
            return {
                "success": False,
                "supported": False,
                "question": question_text,
                "error_message": "Could not parse mathematical question syntax. Please verify symbols, parentheses, and terms."
            }

        degree = poly.degree()
        if degree > 2:
            return {
                "success": False,
                "supported": False,
                "question": question_text,
                "error_message": f"Polynomial of degree {degree} is not supported. This solver supports Grade 10 and 11 linear (degree 1) and quadratic (degree 2) equations."
            }
        elif degree == 0:
            return {
                "success": False,
                "supported": False,
                "question": question_text,
                "error_message": "Variable 'x' cancelled out; the expression does not form a solvable equation."
            }

        # Solve according to degree
        if degree == 1:
            return cls._solve_linear_equation(question_text, lhs_str, rhs_str, lhs_expr, rhs_expr, poly_expr, x)
        elif degree == 2:
            return cls._solve_quadratic_equation(question_text, lhs_str, rhs_str, lhs_expr, rhs_expr, poly_expr, poly, x)

        return {
            "success": False,
            "supported": False,
            "question": question_text,
            "error_message": "Unsupported equation type."
        }

    @classmethod
    def _solve_arithmetic_expression(cls, original_q: str, cleaned_q: str) -> Dict[str, Any]:
        """
        Solves arithmetic questions using standard Order of Operations (BODMAS / PEMDAS).
        Supports expressions like 6 ÷ 2(1 + 2) =, 6 + 2(1 + 2) =, (3 + 5) * 4, etc.
        """
        expr_str = cleaned_q.replace("=", "").strip()
        expr_str = cls.clean_math_text(expr_str)

        # Standardize implicit multiplication: e.g. 2(1+2) -> 2*(1+2), )3 -> )*3, )( -> )*(
        norm_expr = re.sub(r'(\d)\s*\(', r'\1*(', expr_str)
        norm_expr = re.sub(r'\)\s*\(', r')*(', norm_expr)
        norm_expr = re.sub(r'\)\s*(\d)', r')*\1', norm_expr)
        norm_expr = norm_expr.replace("÷", "/").replace("×", "*").replace("^", "**")

        try:
            result = sp.sympify(norm_expr)
        except Exception:
            return {
                "success": False,
                "supported": False,
                "question": original_q,
                "error_message": "Could not evaluate arithmetic expression. Please verify parentheses and operators."
            }

        steps = []
        step_idx = 1

        # Check for parentheses / brackets
        brackets = re.findall(r'\(([^\(\)]+)\)', expr_str)
        subbed = expr_str
        if brackets:
            bracket_details = []
            for b in brackets:
                b_norm = re.sub(r'(\d)\s*\(', r'\1*(', b)
                b_norm = b_norm.replace("÷", "/").replace("×", "*").replace("^", "**")
                try:
                    b_val = sp.sympify(b_norm)
                    bracket_details.append(f"({b}) = {b_val}")
                    subbed = re.sub(r'(\d)\s*\(' + re.escape(b) + r'\)', r'\1 × ' + str(b_val), subbed)
                    subbed = subbed.replace(f"({b})", str(b_val))
                except Exception:
                    pass
            if bracket_details:
                steps.append({
                    "step_number": step_idx,
                    "expression": subbed,
                    "explanation": "Step 1 (Brackets): Evaluate the expression inside parentheses first according to BODMAS rules: " + ", ".join(bracket_details) + "."
                })
                step_idx += 1

        # If expression had division or multiplication, explain order of operations
        if "÷" in expr_str or "/" in expr_str or "*" in expr_str or "×" in expr_str:
            if ("÷" in expr_str or "/" in expr_str) and ("*" in expr_str or "×" in expr_str or "(" in expr_str):
                steps.append({
                    "step_number": step_idx,
                    "expression": f"= {result}",
                    "explanation": "Step 2 (Division & Multiplication): Under standard modern BODMAS / PEMDAS rules, division and multiplication share equal precedence and are performed from left to right."
                })
                step_idx += 1
            else:
                steps.append({
                    "step_number": step_idx,
                    "expression": f"= {result}",
                    "explanation": "Step 2: Evaluate the arithmetic operations following BODMAS precedence (multiplication and division first, then addition and subtraction)."
                })
                step_idx += 1
        else:
            steps.append({
                "step_number": step_idx,
                "expression": f"= {result}",
                "explanation": "Compute the final arithmetic value."
            })
            step_idx += 1

        final_ans = str(int(result)) if (hasattr(result, "is_integer") and result.is_integer) else str(result)

        return {
            "success": True,
            "supported": True,
            "question": original_q,
            "topic": "Order of Operations (BODMAS / Arithmetic)",
            "final_answer": final_ans,
            "steps": steps,
            "roots": [final_ans]
        }

    @classmethod
    def _solve_linear_equation(cls, original_q: str, lhs_str: str, rhs_str: str,
                               lhs_expr, rhs_expr, poly_expr, x) -> Dict[str, Any]:
        """Generates clear, pedagogical steps for linear equations like 2(x + 3) = 14."""
        steps = []
        step_idx = 1

        # Check if brackets need expansion (e.g. 2(x + 3) = 14)
        has_brackets = "(" in lhs_str or "(" in rhs_str
        current_lhs = lhs_expr
        current_rhs = rhs_expr

        if has_brackets:
            expanded_lhs = sp.expand(lhs_expr)
            expanded_rhs = sp.expand(rhs_expr)
            steps.append({
                "step_number": step_idx,
                "expression": f"{expanded_lhs} = {expanded_rhs}",
                "explanation": "Expand the brackets by distributing the multiplying factors across the terms."
            })
            step_idx += 1
            current_lhs = expanded_lhs
            current_rhs = expanded_rhs

        # Step: Collect variable terms if x appears on RHS (e.g. 6x - 4 = 5x + 8)
        rhs_x = current_rhs.coeff(x, 1) if hasattr(current_rhs, "coeff") else 0
        if rhs_x != 0:
            current_lhs = sp.expand(current_lhs - rhs_x * x)
            current_rhs = sp.expand(current_rhs - rhs_x * x)
            if rhs_x > 0:
                op_x = f"Subtract {abs(rhs_x)}x from both sides of the equation to collect variable terms on the left side."
            else:
                op_x = f"Add {abs(rhs_x)}x to both sides of the equation to collect variable terms on the left side."
            steps.append({
                "step_number": step_idx,
                "expression": f"{current_lhs} = {current_rhs}",
                "explanation": op_x
            })
            step_idx += 1

        # Step: Collect constant terms on RHS
        lhs_const = current_lhs.coeff(x, 0) if hasattr(current_lhs, "coeff") else 0
        if lhs_const != 0:
            current_lhs = sp.expand(current_lhs - lhs_const)
            current_rhs = sp.expand(current_rhs - lhs_const)
            if lhs_const > 0:
                op_c = f"Subtract {lhs_const} from both sides of the equation to isolate variable terms."
            else:
                op_c = f"Add {abs(lhs_const)} to both sides of the equation to isolate variable terms."
            steps.append({
                "step_number": step_idx,
                "expression": f"{current_lhs} = {current_rhs}",
                "explanation": op_c
            })
            step_idx += 1

        # Divide by coefficient of x
        a = current_lhs.coeff(x, 1)
        root = sp.Rational(current_rhs, a)
        if root.is_integer:
            final_ans = f"x = {int(root)}"
        else:
            final_ans = f"x = {root.p}/{root.q}"

        if a != 1:
            steps.append({
                "step_number": step_idx,
                "expression": final_ans,
                "explanation": f"Divide both sides by the coefficient {a} to solve for x."
            })
        else:
            steps.append({
                "step_number": step_idx,
                "expression": final_ans,
                "explanation": "Variable x is fully solved."
            })

        return {
            "success": True,
            "supported": True,
            "question": original_q,
            "topic": "Linear Equations",
            "final_answer": final_ans,
            "steps": steps,
            "roots": [str(root)]
        }

    @classmethod
    def _solve_quadratic_equation(cls, original_q: str, lhs_str: str, rhs_str: str,
                                  lhs_expr, rhs_expr, poly_expr, poly, x) -> Dict[str, Any]:
        """Generates clear, pedagogical steps for quadratic equations like 2x² + 5x - 3 = 0."""
        steps = []
        step_idx = 1

        a, b, c = poly.all_coeffs()
        a = sp.Rational(a)
        b = sp.Rational(b)
        c = sp.Rational(c)

        # Step 1: Standard form ax² + bx + c = 0
        std_expr_str = cls._format_quadratic_poly(a, b, c)
        steps.append({
            "step_number": step_idx,
            "expression": f"{std_expr_str} = 0",
            "explanation": "Write the quadratic equation in standard form ax² + bx + c = 0."
        })
        step_idx += 1

        delta = b**2 - 4*a*c
        roots = sp.solve(poly_expr, x)

        formatted_roots = []
        for r in roots:
            if r.is_integer:
                formatted_roots.append(f"x = {int(r)}")
            elif r.is_rational:
                formatted_roots.append(f"x = {r.p}/{r.q}")
            else:
                formatted_roots.append(f"x ≈ {float(r):.2f}")
        final_ans = " or ".join(formatted_roots)

        # Check if difference of squares: a*x^2 - k = 0 (b == 0)
        if b == 0 and c < 0:
            factored = sp.factor(poly_expr)
            steps.append({
                "step_number": step_idx,
                "expression": f"{factored} = 0",
                "explanation": "Apply the difference of squares identity: (p² - q²) = (p - q)(p + q)."
            })
            step_idx += 1
            steps.append({
                "step_number": step_idx,
                "expression": final_ans,
                "explanation": "Equate each factor to zero to find the roots."
            })
            return {
                "success": True,
                "supported": True,
                "question": original_q,
                "topic": "Quadratic Equations (Difference of Squares)",
                "final_answer": final_ans,
                "steps": steps,
                "roots": [str(r) for r in roots]
            }

        # Factorization by middle-term split if delta is a perfect square
        if delta >= 0 and sp.sqrt(delta).is_rational:
            product_ac = int(a * c)
            sum_b = int(b)

            # Find factor pair (p, q)
            p_val, q_val = None, None
            for p in range(-abs(product_ac) - 10, abs(product_ac) + 11):
                if p != 0 and product_ac % p == 0:
                    q = int(product_ac / p)
                    if p + q == sum_b:
                        p_val, q_val = p, q
                        break

            if p_val is not None and q_val is not None:
                p_str = f"+ {p_val}" if p_val > 0 else f"- {abs(p_val)}"
                q_str = f"+ {q_val}" if q_val > 0 else f"- {abs(q_val)}"

                steps.append({
                    "step_number": step_idx,
                    "expression": f"a×c = ({int(a)})×({int(c)}) = {product_ac},  b = {sum_b}",
                    "explanation": f"Find two numbers whose product is {product_ac} and sum is {sum_b}: {p_val} and {q_val}."
                })
                step_idx += 1

                # Step: split middle term
                split_expr = f"{int(a) if a != 1 else ''}x² {p_str}x {q_str}x {f'+ {int(c)}' if c > 0 else f'- {abs(int(c))}'} = 0"
                steps.append({
                    "step_number": step_idx,
                    "expression": split_expr,
                    "explanation": f"Split the middle term {sum_b}x into {p_val}x and {q_val}x."
                })
                step_idx += 1

                # Grouping
                factored = sp.factor(poly_expr)
                steps.append({
                    "step_number": step_idx,
                    "expression": f"{factored} = 0",
                    "explanation": "Factor by grouping common terms from pairs to obtain binomial factors."
                })
                step_idx += 1

                # Equating factors to zero
                eq_steps = "  or  ".join([f"{r}" for r in formatted_roots])
                steps.append({
                    "step_number": step_idx,
                    "expression": eq_steps,
                    "explanation": "Apply the zero-product property: set each linear factor to zero and solve for x."
                })
            else:
                factored = sp.factor(poly_expr)
                steps.append({
                    "step_number": step_idx,
                    "expression": f"{factored} = 0",
                    "explanation": "Factorize the quadratic expression into linear factors."
                })
                step_idx += 1
                steps.append({
                    "step_number": step_idx,
                    "expression": final_ans,
                    "explanation": "Equate each factor to zero to find the roots."
                })
        else:
            # Quadratic Formula
            steps.append({
                "step_number": step_idx,
                "expression": "x = [-b ± √(b² - 4ac)] / (2a)",
                "explanation": "Apply the Quadratic Formula for roots."
            })
            step_idx += 1
            steps.append({
                "step_number": step_idx,
                "expression": f"x = [-({b}) ± √({delta})] / (2×{a})",
                "explanation": f"Substitute coefficients a = {a}, b = {b}, c = {c} into the formula."
            })
            step_idx += 1
            steps.append({
                "step_number": step_idx,
                "expression": final_ans,
                "explanation": "Calculate both roots from the quadratic formula."
            })

        return {
            "success": True,
            "supported": True,
            "question": original_q,
            "topic": "Quadratic Equations",
            "final_answer": final_ans,
            "steps": steps,
            "roots": [str(r) for r in roots]
        }

    @classmethod
    def check_student_working(cls, question_text: str, solution_steps_text: str) -> Dict[str, Any]:
        """
        Evaluates the student's own step-by-step working using consecutive transformation verification.
        1. Solves the benchmark question to know verified roots and reference derivation.
        2. Evaluates each intermediate line against the preceding step and problem constraints.
        3. Distinguishes equivalent transformations from operations that change the solution set,
           introduce extraneous roots, or lose valid solutions.
        4. Detects specific error categories (Sign, Calculation, Expansion, Factorization, Formula, Procedural).
        5. Does not rely only on root substitution; verifies consecutive mathematical transformation validity.
        6. Handles ambiguous notation, incomplete working, and uncertain diagnoses explicitly.
        7. Returns structured feedback: affected step, error category, explanation, rationale, hint, and action.
        """
        solved = cls.solve_question(question_text)
        if not solved.get("success"):
            return {
                "is_correct": False,
                "question": question_text,
                "explanation_text": f"Cannot evaluate working: {solved.get('error_message', 'Unsupported question')}",
                "is_ambiguous": True,
                "uncertainty_notice": "The underlying question could not be verified by the math engine.",
                "correct_steps": []
            }

        correct_roots = solved.get("roots", [])
        final_answer = solved.get("final_answer", "")
        correct_steps = solved.get("steps", [])
        topic = solved.get("topic", "")
        x = sp.Symbol('x')

        if not solution_steps_text or not solution_steps_text.strip():
            return {
                "is_correct": False,
                "question": question_text,
                "failed_step_index": 1,
                "error_category": "Incomplete Working",
                "explanation_text": "No intermediate steps were provided. Please write each derivation step on a new line.",
                "evidence": "Empty solution input.",
                "mathematical_rationale": "Solving an algebraic equation requires demonstrating intermediate logical transformations.",
                "guided_hint": "Start by writing down the initial equation or standard form on the first line.",
                "recommended_action": "Write your first step and submit again.",
                "final_answer": final_answer,
                "correct_steps": correct_steps
            }

        lines = [line.strip() for line in solution_steps_text.strip().split("\n") if line.strip()]

        # -------------------------------------------------------------
        # Branch A: Arithmetic expressions (Order of Operations / BODMAS)
        # -------------------------------------------------------------
        if "BODMAS" in topic or "Arithmetic" in topic or "x" not in question_text.lower():
            try:
                target_val = sp.sympify(final_answer)
            except Exception:
                target_val = None

            for idx, line in enumerate(lines, start=1):
                clean_line = cls.clean_math_text(line).lstrip("=").strip()
                norm_expr = re.sub(r'(\d)\s*\(', r'\1*(', clean_line)
                norm_expr = re.sub(r'\)\s*\(', r')*(', norm_expr)
                norm_expr = re.sub(r'\)\s*(\d)', r')*\1', norm_expr)
                norm_expr = norm_expr.replace("÷", "/").replace("×", "*").replace("^", "**")

                try:
                    step_val = sp.sympify(norm_expr)
                except Exception:
                    return {
                        "is_correct": False,
                        "question": question_text,
                        "failed_step_index": idx,
                        "error_category": "Ambiguous / Syntax Error",
                        "is_ambiguous": True,
                        "uncertainty_notice": "Unable to safely parse arithmetic symbols in this line.",
                        "explanation_text": f"In Line {idx}: Unrecognized arithmetic syntax in '{line}'.",
                        "evidence": f"Expression '{clean_line}' could not be parsed.",
                        "guided_hint": "Check operators (+, -, *, /) and matching parentheses.",
                        "final_answer": final_answer,
                        "correct_steps": correct_steps
                    }

                if target_val is not None and sp.simplify(step_val - target_val) != 0:
                    # Line is incorrect
                    # Distinguish BODMAS precedence error from arithmetic slip
                    err_cat = "Procedural Error (BODMAS Precedence)"
                    if "(" in question_text and "(" not in line:
                        explanation = f"In Line {idx}: Order of operations error. Evaluate expressions inside brackets first according to BODMAS rules."
                    elif "÷" in question_text or "/" in question_text:
                        explanation = f"In Line {idx}: Order of operations error. Division and multiplication share equal precedence and must be evaluated from left to right."
                    else:
                        err_cat = "Calculation Error"
                        explanation = f"In Line {idx}: Arithmetic calculation error. The evaluated value does not equal the verified result."

                    return {
                        "is_correct": False,
                        "question": question_text,
                        "failed_step_index": idx,
                        "error_category": err_cat,
                        "explanation_text": explanation,
                        "evidence": f"Line evaluates to {step_val}, expected progression towards {final_answer}.",
                        "mathematical_rationale": "BODMAS dictates operations order: Brackets, Orders, Division & Multiplication (left-to-right), Addition & Subtraction.",
                        "guided_hint": "Recalculate this step following strict left-to-right precedence.",
                        "corrected_step": f"= {final_answer}",
                        "final_answer": final_answer,
                        "correct_steps": correct_steps
                    }

            # If all arithmetic lines evaluate correctly, verify final value
            last_clean = cls.clean_math_text(lines[-1]).lstrip("=").strip()
            if target_val is not None:
                try:
                    last_val = sp.sympify(last_clean.replace("÷", "/").replace("×", "*").replace("^", "**"))
                    if sp.simplify(last_val - target_val) == 0:
                        return {
                            "is_correct": True,
                            "question": question_text,
                            "final_answer": final_answer,
                            "explanation_text": "Great work! All your intermediate arithmetic steps follow correct BODMAS precedence and lead to the right answer.",
                            "evidence": "All steps preserve numerical equivalence.",
                            "correct_steps": correct_steps
                        }
                except Exception:
                    pass

        # -------------------------------------------------------------
        # Branch B: Algebraic equations with variable x
        # -------------------------------------------------------------
        # 1. Establish initial polynomial state from original question: P_0(x) = LHS - RHS = 0
        orig_cleaned = cls.clean_math_text(question_text)
        if "=" in orig_cleaned:
            q_lhs, q_rhs = orig_cleaned.split("=", 1)
        else:
            q_lhs, q_rhs = orig_cleaned, "0"

        try:
            prev_poly = sp.expand(sp.sympify(cls._to_sympy_expr_str(q_lhs), locals={'x': x}) -
                                  sp.sympify(cls._to_sympy_expr_str(q_rhs), locals={'x': x}))
        except Exception:
            prev_poly = None

        sym_roots = []
        for r_str in correct_roots:
            try:
                sym_roots.append(sp.sympify(r_str))
            except Exception:
                pass

        first_error_idx = None
        error_category = None
        explanation = None
        corrected_step = None
        evidence = None
        math_rationale = None
        guided_hint = None
        recommended_action = None
        is_ambiguous = False
        uncertainty_notice = None

        for idx, line in enumerate(lines, start=1):
            line_clean = cls.clean_math_text(line)

            # Whitelist check for safe algebraic syntax
            if re.search(r'[^0-9a-zA-Z\s\+\-\*\/\^\(\)\.\,\=\:\;]', line_clean) or any(
                bad in line_clean.lower() for bad in ['import', 'exec', 'eval', 'lambda', '__', 'def ']
            ):
                first_error_idx = idx
                error_category = "Ambiguous / Syntax Error"
                is_ambiguous = True
                uncertainty_notice = "Unrecognized mathematical symbols or invalid syntax detected."
                explanation = f"In Line {idx}: Could not safely parse mathematical syntax in '{line}'."
                evidence = f"Line contains invalid characters or unsupported formatting."
                guided_hint = "Use standard algebraic symbols: numbers, +, -, *, /, x, and parentheses."
                recommended_action = "Review line syntax and resubmit."
                break

            # Check for disjunctive branches (e.g. 'x = 1/2 or x = 3', 'x = -2, x = -3', '2x - 1 = 0 or x + 3 = 0')
            branches = [b.strip() for b in re.split(r'\b(?:or|and)\b|[,;]', line_clean) if b.strip()]

            # Sub-check: Root statements (e.g. 'x = 1/2 or x = 3' or 'x = 4')
            is_root_declaration = len(branches) > 0 and all(
                re.match(r'^[a-zA-Z]\s*=\s*[+\-]?\s*\d+(?:\.\d+)?(?:/\d+)?$', b) for b in branches
            )

            if is_root_declaration:
                cand_roots = []
                for b in branches:
                    m = re.search(r'[a-zA-Z]\s*=\s*([+\-]?\s*\d+(?:\.\d+)?(?:/\d+)?)', b)
                    if m:
                        try:
                            cand_roots.append(sp.sympify(m.group(1).replace(" ", "")))
                        except Exception:
                            pass

                # Check if any stated root has a sign error
                sign_err_found = False
                for cr in cand_roots:
                    # If candidate root is not in verified roots, but its negation is
                    if not any(sp.simplify(cr - r) == 0 for r in sym_roots):
                        matching_neg = next((r for r in sym_roots if sp.simplify(cr + r) == 0 and r != 0), None)
                        if matching_neg is not None:
                            first_error_idx = idx
                            error_category = "Sign Error"
                            explanation = f"In Line {idx}: Sign error when transposing across the equals sign. Equating linear factor yields x = {matching_neg}, not x = {cr}."
                            evidence = f"Line states 'x = {cr}', but verified root is {matching_neg}."
                            math_rationale = f"When transposing a term across the equals sign, the sign reverses: (x - {matching_neg}) = 0 implies x = {matching_neg}."
                            guided_hint = f"Check the signs when moving constants across the equals sign."
                            recommended_action = f"Write x = {matching_neg} instead of x = {cr}."
                            corrected_step = final_answer
                            sign_err_found = True
                            break
                        else:
                            # Not a sign flip, but an incorrect root value
                            first_error_idx = idx
                            error_category = "Calculation Error"
                            explanation = f"In Line {idx}: Calculation error. The value x = {cr} does not satisfy the original equation."
                            evidence = f"Value x = {cr} is not a valid root."
                            math_rationale = f"Verified roots for this equation are {final_answer}."
                            guided_hint = "Double-check your division or factoring arithmetic."
                            recommended_action = f"Conclude with the verified roots: {final_answer}."
                            corrected_step = final_answer
                            sign_err_found = True
                            break

                if sign_err_found:
                    break

                # If all candidate roots match verified roots
                if len(cand_roots) == len(sym_roots) and all(any(sp.simplify(cr - r) == 0 for r in sym_roots) for cr in cand_roots):
                    # Roots are valid and complete!
                    continue
                elif len(cand_roots) < len(sym_roots) and idx == len(lines):
                    first_error_idx = idx
                    error_category = "Incomplete Working"
                    explanation = f"In Line {idx}: Incomplete roots. A quadratic equation has two roots, but only {len(cand_roots)} was given."
                    evidence = f"Provided: {cand_roots}, Expected: {final_answer}."
                    guided_hint = f"State both roots: {final_answer}."
                    corrected_step = final_answer
                    break

            # Sub-check: Linear factor branching (Zero-Product Property, e.g. '2x - 1 = 0 or x + 3 = 0')
            is_factor_branching = len(branches) > 1 and all("=" in b for b in branches)
            if is_factor_branching:
                branch_factors = []
                branch_parse_ok = True
                for b in branches:
                    b_l, b_r = b.split("=", 1)
                    try:
                        bf = sp.expand(sp.sympify(cls._to_sympy_expr_str(b_l), locals={'x': x}) -
                                       sp.sympify(cls._to_sympy_expr_str(b_r), locals={'x': x}))
                        branch_factors.append(bf)
                    except Exception:
                        branch_parse_ok = False
                        break

                if branch_parse_ok and branch_factors:
                    product_poly = sp.expand(branch_factors[0] * branch_factors[1])
                    if prev_poly is not None:
                        diff = sp.simplify(product_poly - prev_poly)
                        ratio = sp.simplify(product_poly / prev_poly)
                        if diff == 0 or (ratio.is_number and ratio != 0):
                            # Valid application of zero-product property
                            prev_poly = product_poly
                            continue
                        else:
                            # Factors do not multiply to previous polynomial
                            first_error_idx = idx
                            # Check if it was a sign flip in factors
                            neg_product = sp.expand((-branch_factors[0]) * branch_factors[1])
                            if sp.simplify(neg_product - prev_poly) == 0 or any(
                                abs(sp.Poly(product_poly, x).all_coeffs()[-1]) == abs(sp.Poly(prev_poly, x).all_coeffs()[-1])
                            ):
                                error_category = "Sign Error"
                                explanation = f"In Line {idx}: Sign error in linear factors. The linear factors do not multiply back to the original equation."
                            else:
                                error_category = "Factorization Error"
                                explanation = f"In Line {idx}: Factorization error. Setting '{line}' does not match the factors of the quadratic equation."

                            evidence = f"Product of factors {product_poly} != {prev_poly}."
                            math_rationale = "The zero-product property requires that (ax + b)(cx + d) = 0 splits into exact factors ax + b = 0 or cx + d = 0."
                            guided_hint = "Verify the signs and coefficients of your linear factors."
                            corrected_step = correct_steps[min(idx - 1, len(correct_steps) - 1)]["expression"] if correct_steps else final_answer
                            break

            # Sub-check: Standard progressive equation line (LHS = RHS)
            if "=" in line_clean:
                l_part, r_part = line_clean.split("=", 1)
                try:
                    curr_lhs = sp.sympify(cls._to_sympy_expr_str(l_part), locals={'x': x})
                    curr_rhs = sp.sympify(cls._to_sympy_expr_str(r_part), locals={'x': x})
                    curr_poly = sp.expand(curr_lhs - curr_rhs)
                except Exception:
                    # Could not parse line
                    first_error_idx = idx
                    error_category = "Ambiguous / Syntax Error"
                    is_ambiguous = True
                    uncertainty_notice = "Could not parse intermediate algebraic expression."
                    explanation = f"In Line {idx}: Syntax error in equation '{line}'."
                    evidence = f"Unable to parse LHS or RHS into symbolic form."
                    break

                if prev_poly is None:
                    prev_poly = curr_poly
                    continue

                # 1. Consecutive Equivalence Verification
                diff = sp.simplify(curr_poly - prev_poly)
                ratio = sp.simplify(curr_poly / prev_poly) if prev_poly != 0 else None
                is_equiv = (diff == 0) or (ratio is not None and ratio.is_number and ratio != 0)

                if is_equiv:
                    # Valid step!
                    prev_poly = curr_poly
                    continue

                # 2. Step is NOT equivalent — diagnose the exact mathematical failure
                first_error_idx = idx
                deg_curr = sp.Poly(curr_poly, x).degree() if "x" in str(curr_poly) else 0
                deg_prev = sp.Poly(prev_poly, x).degree() if "x" in str(prev_poly) else 0

                # Check A: Extraneous solutions introduced (degree jump)
                if deg_curr > deg_prev:
                    error_category = "Invalid Algebraic Transformation"
                    explanation = f"In Line {idx}: Extraneous solutions introduced. The transformation increases the equation degree from {deg_prev} to {deg_curr}."
                    evidence = f"Line '{line}' has degree {deg_curr}, exceeding original problem degree {deg_prev}."
                    math_rationale = "Algebraic transformations must preserve the exact solution set without introducing extraneous roots."
                    guided_hint = "Do not multiply the equation by an unnecessary polynomial expression."
                    corrected_step = correct_steps[min(idx - 1, len(correct_steps) - 1)]["expression"] if correct_steps else final_answer
                    break

                # Check B: Lost solutions (degree drop without disjunction)
                if deg_curr < deg_prev and deg_prev > 1:
                    error_category = "Procedural Error (Lost Solution)"
                    explanation = f"In Line {idx}: Procedural error. Dividing by variable x eliminates valid roots (degree dropped from {deg_prev} to {deg_curr})."
                    evidence = f"Equation degree reduced from {deg_prev} to {deg_curr}."
                    math_rationale = "Do not divide an equation by a variable factor that can equal zero, as this permanently eliminates solutions."
                    guided_hint = "Factor out the common variable term instead of dividing by it."
                    corrected_step = correct_steps[min(idx - 1, len(correct_steps) - 1)]["expression"] if correct_steps else final_answer
                    break

                # Check C & D: Transposition sign error vs Expansion error vs Calculation error
                try:
                    poly_c = sp.Poly(curr_poly, x)
                    poly_p = sp.Poly(prev_poly, x)
                    coeffs_c = poly_c.all_coeffs()
                    coeffs_p = poly_p.all_coeffs()

                    had_brackets_to_expand = ("(" in l_part or "(" in r_part) or (idx == 1 and "(" in orig_cleaned) or (idx > 1 and "(" in lines[idx - 2])

                    if had_brackets_to_expand and (idx == 1 or ("(" in lines[idx - 2] and "(" not in line_clean)):
                        error_category = "Expansion Error"
                        explanation = f"In Line {idx}: Distributive property error. Terms inside parentheses were not multiplied correctly."
                        evidence = f"Expanding parentheses in '{line}' yields {curr_poly} != {prev_poly}."
                        math_rationale = "The distributive law a(b + c) = ab + ac requires multiplying every term inside parentheses."
                        guided_hint = "Ensure the multiplier outside brackets multiplies every term inside."
                        corrected_step = correct_steps[min(idx - 1, len(correct_steps) - 1)]["expression"] if correct_steps else final_answer
                        break
                    elif len(coeffs_c) == len(coeffs_p) and coeffs_c[:-1] == coeffs_p[:-1]:
                        # Variable coefficients match, but constant term differs
                        error_category = "Sign Error"
                        explanation = f"In Line {idx}: Sign error when transposing terms across the equals sign."
                        evidence = f"Constant term in '{line}' reflects an inverted transposition sign."
                        math_rationale = "When moving a term across the equals sign, its sign reverses (+ becomes -, and - becomes +)."
                        guided_hint = "Check the sign of the constant term when moving it to the opposite side."
                        corrected_step = correct_steps[min(idx - 1, len(correct_steps) - 1)]["expression"] if correct_steps else final_answer
                        break
                    else:
                        error_category = "Arithmetic / Transformation Error"
                        explanation = f"In Line {idx}: Transformation error. The equation on this line is not mathematically equivalent to the previous step."
                        evidence = f"Simplifying '{line}' yields {curr_poly} = 0, which does not equal {prev_poly} = 0."
                        math_rationale = "Each progressive equation line must preserve mathematical equivalence."
                        guided_hint = "Check your algebraic operations on both sides of the equation."
                        corrected_step = correct_steps[min(idx - 1, len(correct_steps) - 1)]["expression"] if correct_steps else final_answer
                        break
                except Exception:
                    error_category = "Arithmetic / Transformation Error"
                    explanation = f"In Line {idx}: The algebraic expression on this line is not equivalent to the previous step."
                    evidence = f"Transformation does not preserve equality."
                    corrected_step = correct_steps[min(idx - 1, len(correct_steps) - 1)]["expression"] if correct_steps else final_answer
                    break

        # Check conclusion if no step error was flagged during loop
        if not first_error_idx:
            last_line = lines[-1].replace(" ", "").lower()
            all_roots_present = True
            for r in correct_roots:
                sym_r = sp.sympify(r)
                candidates = []
                if sym_r.is_integer:
                    candidates.append(str(int(sym_r)))
                elif sym_r.is_rational:
                    candidates.append(f"{sym_r.p}/{sym_r.q}")
                    candidates.append(str(float(sym_r)))
                else:
                    candidates.append(f"{float(sym_r):.2f}")
                    candidates.append(str(float(sym_r)))

                if not any(cand in last_line for cand in candidates):
                    all_roots_present = False
                    break

            if all_roots_present and len(lines) >= 1:
                return {
                    "is_correct": True,
                    "question": question_text,
                    "final_answer": final_answer,
                    "explanation_text": "Great work! All your intermediate mathematical derivation steps are valid and lead to the correct answer.",
                    "evidence": "Consecutive step transformations preserve mathematical equivalence and verified roots are reached.",
                    "mathematical_rationale": "Every consecutive transformation preserves the algebraic solution set.",
                    "guided_hint": "Proceed to the next question or practice topic.",
                    "recommended_action": "Continue with your adaptive learning pathway.",
                    "correct_steps": correct_steps
                }
            else:
                first_error_idx = len(lines)
                error_category = "Incomplete / Incorrect Conclusion"
                explanation = f"In Line {len(lines)}: The solution does not conclude with the verified roots. Expected: {final_answer}."
                evidence = f"Last line '{lines[-1]}' does not match expected result."
                math_rationale = f"A complete mathematical solution must conclude with the verified values for variable x: {final_answer}."
                guided_hint = f"State the final values of x: {final_answer}."
                recommended_action = f"Complete the working by stating: {final_answer}."
                corrected_step = final_answer

        return {
            "is_correct": False,
            "question": question_text,
            "failed_step_index": first_error_idx,
            "error_category": error_category or "Algebraic Error",
            "explanation_text": explanation or "A mathematical error was detected in your solution.",
            "corrected_step": corrected_step,
            "evidence": evidence,
            "mathematical_rationale": math_rationale,
            "guided_hint": guided_hint,
            "recommended_action": recommended_action,
            "is_ambiguous": is_ambiguous,
            "uncertainty_notice": uncertainty_notice,
            "final_answer": final_answer,
            "correct_steps": correct_steps
        }

    @staticmethod
    def _format_quadratic_poly(a, b, c) -> str:
        parts = []
        if a == 1:
            parts.append("x²")
        elif a == -1:
            parts.append("-x²")
        else:
            parts.append(f"{int(a) if a.is_integer else a}x²")

        if b != 0:
            if b > 0:
                parts.append(f"+ {int(b) if b.is_integer else b}x")
            else:
                parts.append(f"- {abs(int(b) if b.is_integer else b)}x")

        if c != 0:
            if c > 0:
                parts.append(f"+ {int(c) if c.is_integer else c}")
            else:
                parts.append(f"- {abs(int(c) if c.is_integer else c)}")

        return " ".join(parts)

    @staticmethod
    def _to_sympy_expr_str(s: str) -> str:
        s = s.replace("^", "**")
        s = re.sub(r'(\d+)\s*\(', r'\1*(', s)
        s = re.sub(r'\)\s*(\d+)', r')*\1', s)
        s = re.sub(r'(\d+)\s*([a-zA-Z])', r'\1*\2', s)
        s = re.sub(r'\)\s*([a-zA-Z])', r')*\1', s)
        s = re.sub(r'([a-zA-Z])\s*\(', r'\1*(', s)
        s = re.sub(r'\)\s*\(', r')*(', s)
        return s.strip()
