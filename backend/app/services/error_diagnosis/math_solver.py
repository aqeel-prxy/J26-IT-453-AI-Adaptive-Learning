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
        s = re.sub(r'^(?:solve|find x in|factorise and solve|evaluate|calculate)\s*[:\-]?\s*', '', s, flags=re.I)
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

        # Must contain variable x
        if "x" not in lower_q:
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
        Evaluates the student's own step-by-step working:
        1. Solves the benchmark question to know the verified roots.
        2. Evaluates each intermediate line mathematically using symbolic equivalence.
        3. Identifies the first incorrect line if an error exists.
        4. Classifies error taxonomy (Sign Error, Arithmetic Error, Expansion Error, Incomplete).
        5. Does not penalize valid alternative methods.
        """
        solved = cls.solve_question(question_text)
        if not solved.get("success"):
            return {
                "is_correct": False,
                "question": question_text,
                "explanation_text": f"Cannot evaluate working: {solved.get('error_message')}",
                "is_ambiguous": True,
                "uncertainty_notice": "The underlying question could not be verified by the math engine.",
                "correct_steps": []
            }

        correct_roots = solved.get("roots", [])
        final_answer = solved.get("final_answer", "")
        correct_steps = solved.get("steps", [])
        x = sp.Symbol('x')

        if not solution_steps_text or not solution_steps_text.strip():
            return {
                "is_correct": False,
                "question": question_text,
                "failed_step_index": 1,
                "error_category": "Incomplete Working",
                "explanation_text": "No intermediate steps were provided. Please write each derivation line on a new line.",
                "evidence": "Empty solution input.",
                "final_answer": final_answer,
                "correct_steps": correct_steps
            }

        lines = [line.strip() for line in solution_steps_text.strip().split("\n") if line.strip()]

        # Line-by-line verification
        first_error_idx = None
        error_category = None
        explanation = None
        corrected_step = None
        evidence = None

        for idx, line in enumerate(lines, start=1):
            line_clean = cls.clean_math_text(line)
            
            # Check for sign transposition error: factor (x + k) = 0 => x = +k
            line_no_space = line_clean.replace(" ", "").lower()
            for r_str in correct_roots:
                try:
                    r_val = sp.sympify(r_str)
                    if r_val.is_real and r_val < 0:
                        pos_k = abs(int(r_val)) if r_val.is_integer else abs(float(r_val))
                        # If student wrote x = pos_k when it should be negative
                        if f"x={pos_k}" in line_no_space and f"x=-{pos_k}" not in line_no_space:
                            first_error_idx = idx
                            error_category = "Sign Error"
                            explanation = f"In Line {idx}: Sign error when transposing across the equals sign. Equating factor (x + {pos_k}) = 0 yields x = -{pos_k}, not +{pos_k}."
                            evidence = f"Line contains 'x = {pos_k}', but root is -{pos_k}."
                            corrected_step = f"x = -{pos_k}"
                            break
                    elif r_val.is_real and r_val > 0:
                        pos_k = int(r_val) if r_val.is_integer else float(r_val)
                        if f"x=-{pos_k}" in line_no_space and f"x={pos_k}" not in line_no_space:
                            first_error_idx = idx
                            error_category = "Sign Error"
                            explanation = f"In Line {idx}: Sign error. Equating (x - {pos_k}) = 0 yields x = {pos_k}, not -{pos_k}."
                            evidence = f"Line contains 'x = -{pos_k}', but root is +{pos_k}."
                            corrected_step = f"x = {pos_k}"
                            break
                except Exception:
                    pass

            if first_error_idx:
                break

            # Check equation line mathematical equivalence
            if "=" in line_clean:
                l_part, r_part = line_clean.split("=", 1)
                try:
                    prep_l = cls._to_sympy_expr_str(l_part)
                    prep_r = cls._to_sympy_expr_str(r_part)
                    line_expr = sp.expand(sp.sympify(prep_l) - sp.sympify(prep_r))
                    
                    # Verify if this step is satisfied by all correct roots
                    # For a valid step, substituting the correct roots must yield 0
                    is_line_valid = True
                    for r_str in correct_roots:
                        sub_val = sp.sympify(line_expr).subs(x, sp.sympify(r_str))
                        if sp.simplify(sub_val) != 0:
                            is_line_valid = False
                            break

                    if not is_line_valid:
                        first_error_idx = idx
                        # Determine category
                        if "(" in l_part and ")" in l_part:
                            error_category = "Expansion / Factorization Error"
                            explanation = f"In Line {idx}: The algebraic expansion or factorization does not preserve equality with the roots."
                        else:
                            error_category = "Arithmetic / Transformation Error"
                            explanation = f"In Line {idx}: Transformation error. The algebraic expression on this line is not mathematically equivalent to the original equation."
                        evidence = f"Substituting verified root into '{line}' does not yield equality."
                        corrected_step = correct_steps[min(idx - 1, len(correct_steps) - 1)]["expression"] if correct_steps else None
                        break
                except Exception:
                    # Ignore minor formatting if it's the final line with 'or'
                    pass

        # Check final line for roots
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
                    "evidence": "All lines preserve mathematical equivalence and verified roots are reached.",
                    "correct_steps": correct_steps
                }
            else:
                first_error_idx = len(lines)
                error_category = "Incomplete / Incorrect Conclusion"
                explanation = f"In Line {len(lines)}: The solution does not conclude with the verified roots. Expected: {final_answer}."
                evidence = f"Last line '{lines[-1]}' does not match expected result."
                corrected_step = final_answer

        return {
            "is_correct": False,
            "question": question_text,
            "failed_step_index": first_error_idx,
            "error_category": error_category or "Algebraic Error",
            "explanation_text": explanation or "A mathematical error was detected in your solution.",
            "corrected_step": corrected_step,
            "evidence": evidence,
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
