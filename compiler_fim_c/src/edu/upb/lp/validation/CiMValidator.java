package edu.upb.lp.validation;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.xtext.validation.Check;

import com.google.common.reflect.Parameter;

import edu.upb.lp.ciM.CiMPackage;
import edu.upb.lp.ciM.Comparison;
import edu.upb.lp.ciM.Declaration;
import edu.upb.lp.ciM.Expression;
import edu.upb.lp.ciM.Function;
import edu.upb.lp.ciM.FunctionCall;
import edu.upb.lp.ciM.Instruction;
import edu.upb.lp.ciM.Program;
import edu.upb.lp.ciM.Return;
import edu.upb.lp.ciM.Variable;
import edu.upb.lp.ciM.VariableReference;

public class CiMValidator extends AbstractCiMValidator {

    // Validador para el nombre de la función
    @Check
    public void checkFunctionName(Function function) {
        if (!function.getName().equals(function.getNameClose())) {
            error("Function name and closing name must match",
                  CiMPackage.Literals.FUNCTION__NAME_CLOSE);
        }
    }

    // Validador para la declaración de variables
    @Check
    public void checkUniqueVariableNames(Program program) {
        Set<String> variableNames = new HashSet<>();
        for (Declaration variable : program.getDeclarations()) {
            if (!variableNames.add(variable.getName())) {
                error("Variable '" + variable.getName() + "' is already declared",
                      CiMPackage.Literals.VARIABLE__NAME);
            }
        }
    }

    // Validador para el tipo de retorno de una función
    @Check
    public void checkReturnType(Function function) {
        if (function.getReturnType() != null && function.getInstructions() != null) {
            for (Instruction instruction : function.getInstructions()) {
                if (instruction instanceof Return) {
                    Return returnStatement = (Return) instruction;
                    if (!returnStatement.getVal().getType().equals(function.getReturnType())) {
                        error("Return type does not match function's return type",
                              CiMPackage.Literals.RETURN__VAL);
                    }
                }
            }
        }
    }

    // Validador para la asignación de variables
    @Check
    public void checkVariableAssignment(Variable assignment) {
        Expression varRef = assignment.getValue();
        if (varRef != null && assignment.getValue() != null) {
            if (!varRef.getVar().getType().equals(assignment.getValue().getType())) {
                error("Variable type does not match assigned value type",
                      CiMPackage.Literals.VARIABLE_ASSIGNMENT__VALUE);
            }
        }
    }

    // Validador para las comparaciones
    @Check
    public void checkComparison(Comparison comparison) {
        if (comparison.getVal1().getType() != comparison.getVal2().getType()) {
            error("Comparisons must be between expressions of the same type",
                  CiMPackage.Literals.COMPARISON__VAL1);
        }
    }

    // Validador para la llamada de funciones
    @Check
    public void checkFunctionCall(FunctionCall functionCall) {
        if (functionCall.getFunction() != null) {
            int paramSize = functionCall.getFunction().getParams().size();
            int argSize = functionCall.getArgs().size();
            if (paramSize != argSize) {
                error("los parametros no son la misma cantidad",
                      CiMPackage.Literals.FUNCTION_CALL__ARGS);
            } else {
                for (int i = 0; i < paramSize; i++) {
                    Variable param = functionCall.getFunction().getParams().get(i);
                    if (!param.getType().equals(functionCall.getArgs().get(i).getType())) {
                        error("Argument type does not match parameter type",
                              CiMPackage.Literals.FUNCTION_CALL__ARGS, i);
                    }
                }
            }
        }
    }
}

