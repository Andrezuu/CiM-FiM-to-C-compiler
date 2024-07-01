/*
 * generated by Xtext 2.35.0
 */
package edu.upb.lp.generator

import edu.upb.lp.ciM.BooleanExpression
import edu.upb.lp.ciM.BooleanLiteral
import edu.upb.lp.ciM.Comparison
import edu.upb.lp.ciM.Decrement
import edu.upb.lp.ciM.Division
import edu.upb.lp.ciM.ElseStatement
import edu.upb.lp.ciM.Equal
import edu.upb.lp.ciM.FalseLiteral
import edu.upb.lp.ciM.ForStatement
import edu.upb.lp.ciM.Function
import edu.upb.lp.ciM.FunctionCall
import edu.upb.lp.ciM.IfStatement
import edu.upb.lp.ciM.Increment
import edu.upb.lp.ciM.Input
import edu.upb.lp.ciM.IntExpression
import edu.upb.lp.ciM.IntLiteral
import edu.upb.lp.ciM.LessThan
import edu.upb.lp.ciM.LessThanOrEqual
import edu.upb.lp.ciM.MathExpression
import edu.upb.lp.ciM.MoreThan
import edu.upb.lp.ciM.MoreThanOrEqual
import edu.upb.lp.ciM.Multiplication
import edu.upb.lp.ciM.NoTypeExpression
import edu.upb.lp.ciM.NotEqual
import edu.upb.lp.ciM.Print
import edu.upb.lp.ciM.Program
import edu.upb.lp.ciM.Statement
import edu.upb.lp.ciM.StringLiteral
import edu.upb.lp.ciM.Substraction
import edu.upb.lp.ciM.Sum
import edu.upb.lp.ciM.TrueLiteral
import edu.upb.lp.ciM.Variable
import edu.upb.lp.ciM.VariableReference
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class CiMGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
//		fsa.generateFile('greetings.txt', 'People to greet: ' + 
//			resource.allContents
//				.filter(Greeting)
//				.map[name]
//				.join(', '))
		val p = resource.allContents.head as Program
		fsa.generateFile(p.name + ".cpp", generateProgram(p));
	}

	def generateProgram(Program p) {
		'''
			#include <iostream>
			#include <cmath>
			using namespace std;
			«FOR declaration : p.declarations»«processDeclaration(declaration)»«ENDFOR»
			«processMainFunction(p.main)»
			
		'''
	}

	def dispatch processDeclaration(Variable variable) {
		processVariable(variable)
	}

	def dispatch processDeclaration(Function function) {
		processFunction(function)
	}

	def dispatch processInstruction(Variable variable) {
		processVariable(variable)
	}

	def dispatch processInstruction(Statement statement) {
		processStatement(statement)
	}

	def dispatch processInstruction(FunctionCall functionCall) {
		processFunctionCall(functionCall)
	}

	def processMainFunction(Function mainFunction) {
		'''
			int main() {
			«FOR inst : mainFunction.instructions»«processInstruction(inst)»«ENDFOR»
			return 0;
			}
		'''
	}

	def processFunction(Function function) {
		'''
			«IF function.returnType !==null» «function.returnType.toLowerCase» «ELSE» void «ENDIF» «function.name» ( «IF !(function.params.isNullOrEmpty)» «processParameters(function.params)» «ENDIF» ) {
			«FOR inst : function.instructions»«processInstruction(inst)»«ENDFOR»
			}
		'''
	}

	def processFunctionCall(FunctionCall funcCall) {
		'''«funcCall.function.name»(«FOR arg : funcCall.args» «processExpression(arg)»«IF !arg.equals(funcCall.args.last)», «ENDIF»«ENDFOR»);'''
	}

	def processVariable(Variable variable) {
		'''
			«variable.type.toLowerCase» «variable.name» «IF variable.value !== null»= «processExpression(variable.value)»«ENDIF»;
		'''
	}

	def processForVariable(Variable variable) {
		'''
			«variable.type.toLowerCase» «variable.name»	
		'''
	}

	def dispatch processStatement(IfStatement ifStatement) '''
		if ( «processExpression(ifStatement.condition)» ) {
		«FOR inst : ifStatement.instructions»«processInstruction(inst)»«ENDFOR»	} «IF ifStatement.^else !== null»«processStatement(ifStatement.^else as ElseStatement)»«ENDIF»
	'''

	def dispatch processStatement(ElseStatement elseStatement) {
		'''
			else {
				«FOR inst : elseStatement.instructions»«processInstruction(inst)»«ENDFOR»
			}
		'''
	}

	def dispatch processStatement(Print printStatement) {
		'''
			cout<<«processExpression(printStatement.value)»<<endl;
		'''
	}

	def dispatch processStatement(Input inputStatement) {
		'''
			«IF inputStatement.prompt !== null»cout<<«inputStatement.prompt»;«ENDIF»
			cin>>«inputStatement.getVar()»;
		'''
	}

	def dispatch processStatement(ForStatement forStatement) '''
		for(«processForVariable(forStatement.^var)» = max(«processExpression(forStatement.val1)»,«processExpression(forStatement.val2)»); «forStatement.^var.name» > abs(«processExpression(forStatement.val1)»-«processExpression(forStatement.val2)»); «forStatement.^var.name»--)  {
			«FOR inst : forStatement.instructions»«processInstruction(inst)»«ENDFOR»
		}
	'''

	def processParameters(EList<Variable> params) {
		'''
			«FOR param : params»«param.type.toLowerCase» «param.name»«IF !param.equals(params.last)», «ENDIF»«ENDFOR»
		'''
	}

	def dispatch processExpression(NoTypeExpression noTypeExpression) {
		processNoTypeExpression(noTypeExpression)
	}

	def dispatch processExpression(StringLiteral stringLiteral) {
		''' "«stringLiteral.value»" '''
	}

	def dispatch processExpression(BooleanExpression booleanExpression) {
		processBooleanExpression(booleanExpression)
	}

	// BOOLEAN EXPRESSIONS
	def dispatch processBooleanExpression(BooleanLiteral booleanLiteral) {
		processBooleanLiteral(booleanLiteral)

	}

	def dispatch processBooleanExpression(Comparison comparison) {
		processComparison(comparison)
	}

	// BOOLEAN LITERALS
	def dispatch processBooleanLiteral(TrueLiteral trueLiteral) {
		'''«trueLiteral.value»'''
	}

	def dispatch processBooleanLiteral(FalseLiteral falseLiteral) {
		'''«falseLiteral.value»'''
	}

	// COMPARISONS
	def dispatch processComparison(Equal equal) {
		'''«processExpression(equal.val1)» == «processExpression(equal.val2)»'''
	}

	def dispatch processComparison(NotEqual notEqual) {
		'''«processExpression(notEqual.val1)» != «processExpression(notEqual.val2)»'''
	}

	def dispatch processComparison(LessThan lessThan) {
		'''«processExpression(lessThan.val1)» < «processExpression(lessThan.val2)»'''
	}

	def dispatch processComparison(LessThanOrEqual lessThanOrEqual) {
		'''«processExpression(lessThanOrEqual.val1)» <= «processExpression(lessThanOrEqual.val2)»'''
	}

	def dispatch processComparison(MoreThan moreThan) {
		'''«processExpression(moreThan.val1)» > «processExpression(moreThan.val2)»'''
	}

	def dispatch processComparison(MoreThanOrEqual moreThanOrEqual) {
		'''«processExpression(moreThanOrEqual.val1)» >= «processExpression(moreThanOrEqual.val2)»'''
	}

	// INT EXPRESSIONS
	def dispatch processExpression(IntExpression intExpression) {
		processIntExpression(intExpression)
	}

	def dispatch processIntExpression(IntLiteral intLiteral) {
		'''«intLiteral.value»'''
	}

	def dispatch processIntExpression(MathExpression mathExpression) {
		processMathExpression(mathExpression)
	}

	// math
	def dispatch processMathExpression(Increment increment) {
		'''«increment.^var.name»++;'''
	}

	def dispatch processMathExpression(Decrement decrement) {
		'''«decrement.^var.name»--;'''
	}

	def dispatch processMathExpression(Sum sum) {
		'''«processExpression(sum.val1)» + «processExpression(sum.val2)»'''
	}

	def dispatch processMathExpression(Substraction substraction) {
		'''«processExpression(substraction.val1)» - «processExpression(substraction.val2)»'''
	}

	def dispatch processMathExpression(Multiplication multiplication) {
		'''«processExpression(multiplication.val1)» * «processExpression(multiplication.val2)»'''
	}

	def dispatch processMathExpression(Division division) {
		'''«processExpression(division.val1)» / «processExpression(division.val2)»'''
	}

	// NO TYPE EXPRESSIONS
	def dispatch processNoTypeExpression(VariableReference varReference) {
		'''«varReference.^var.name»'''
	}

	def dispatch processNoTypeExpression(FunctionCall funcCall) {
		processFunctionCall(funcCall)
	}

}
