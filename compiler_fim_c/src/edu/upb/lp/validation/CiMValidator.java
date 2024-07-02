package edu.upb.lp.validation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.validation.Check;

import edu.upb.lp.ciM.BooleanArrayLiteral;
import edu.upb.lp.ciM.BooleanExpression;
import edu.upb.lp.ciM.CiMPackage;
import edu.upb.lp.ciM.Declaration;
import edu.upb.lp.ciM.Expression;
import edu.upb.lp.ciM.Function;
import edu.upb.lp.ciM.IntArrayLiteral;
import edu.upb.lp.ciM.IntExpression;
import edu.upb.lp.ciM.IntLiteral;
import edu.upb.lp.ciM.Program;
import edu.upb.lp.ciM.Variable;
import edu.upb.lp.ciM.VariableReference;

public class CiMValidator extends AbstractCiMValidator {

	@Check
	public void checkConstantExpressionValues(IntLiteral intLiteral) {
		int value = intLiteral.getValue();
		if (value < 0) {
			error("Negativo ??? NO", intLiteral, null);
		}
	}

	@Check
	public void checkVariableDeclaration(VariableReference varRef) {
		if (varRef.getVar() == null) {
			error("Declara la variable, wey....", varRef, null);
		}
	}

	@Check
	public void checkDuplicateVariableDeclarations(Variable var) {
		EObject container = var.eContainer();
		if (container instanceof Program) {
			Program program = (Program) container;
			for (Declaration decl : program.getDeclarations()) {
				if (decl instanceof Variable) {
					Variable otherVar = (Variable) decl;
					if (otherVar != var && otherVar.getName().equals(var.getName())) {
						error("Hay otra variable igual. Busca.... " + var.getName(), var, null);
					}
				}
			}
		}
	}

	@Check
	public void checkVariableDeclaration(Variable var) {
		if (var.getName() == null || var.getName().isEmpty()) {
			error("Variable name must be specified", var, null);
		}

		// Validación de tipo de datos
		String type = var.getType();
		if (!(type.equals("Bool") || type.equals("Int") || type.equals("String") || type.equals("Int[]")
				|| type.equals("Bool[]"))) {
			error("Invalid type specified for variable", var, null);
		}

		// Validación de inicialización de variables
		if (var.getValue() != null) {
			Expression value = var.getValue();
			if (type.equals("Int") && !(value instanceof IntExpression)) {
				error("Y el INT???", var, null);
			} else if (type.equals("Bool") && !(value instanceof BooleanExpression)) {
				error("Y el Boolean ???", var, null);
			} else if (type.equals("String")) {
				if (!(value instanceof edu.upb.lp.ciM.StringLiteral)) {
					error("Y el String??", CiMPackage.Literals.VARIABLE__VALUE);
				}
			} else if (type.equals("Int[]") && !(value instanceof IntArrayLiteral)) {
				error("Wey esperabna un Int[], que paso?", var, null);
			} else if (type.equals("Bool[]") && !(value instanceof BooleanArrayLiteral)) {
				error("Wey esperaba un Bool[], que paso?", var, null);
			}
		}
	}

	public static final String INVALID_NAME = "invalidName";
	public static final String TYPE_MISMATCH = "typeMismatch";
	public static final String UNDECLARED_VARIABLE = "undeclaredVariable";
	public static final String INVALID_BOOLEAN_LITERAL = "invalidBooleanLiteral";

	@Check
	public void isFunctionOpenEqualClose(Function f) {
		if (!(f.getName().equals(f.getNameClose()))) {
			error("No es igual al nombre de la Funcion WEY!!!", CiMPackage.Literals.FUNCTION__NAME_CLOSE);
		}
	}

	@Check
	public void checkVariableType(Variable v) {
		Expression value = v.getValue();
		String type = v.getType();
		if (value == null) {
			return;
		}

		if (type.equals("Int")) {
			if (!(value instanceof edu.upb.lp.ciM.IntLiteral)) {
				error("y el Int??", CiMPackage.Literals.VARIABLE__VALUE);
			}
		} else if (type.equals("Bool")) {
			if (!(value instanceof edu.upb.lp.ciM.BooleanLiteral)) {
				error("Y el boolean??", CiMPackage.Literals.VARIABLE__VALUE);
			}
		} else if (type.equals("String")) {
			if (!(value instanceof edu.upb.lp.ciM.StringLiteral)) {
				error("Y el String??", CiMPackage.Literals.VARIABLE__VALUE);
			}
		}
	}

	@Check
	public void checkVariableReference(VariableReference ref) {
		if (ref.getVar() == null) {
			error("Y la referencia??", CiMPackage.Literals.VARIABLE_REFERENCE__VAR);
		}
	}

}