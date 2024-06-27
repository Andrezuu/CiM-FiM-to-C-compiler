/*
 * generated by Xtext 2.35.0
 */
package edu.upb.lp.generator

import edu.upb.lp.ciM.BooleanExpression
import edu.upb.lp.ciM.BooleanLiteral
import edu.upb.lp.ciM.ElseStatement
import edu.upb.lp.ciM.ForStatement
import edu.upb.lp.ciM.Function
import edu.upb.lp.ciM.IfStatement
import edu.upb.lp.ciM.Input
import edu.upb.lp.ciM.IntExpression
import edu.upb.lp.ciM.Parameter
import edu.upb.lp.ciM.Print
import edu.upb.lp.ciM.Program
import edu.upb.lp.ciM.StringLiteral
import edu.upb.lp.ciM.Variable
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
			using namespace std;
			«FOR atribute : p.attributes» «processVariable(atribute)» «ENDFOR»
			«FOR function : p.func» «processFunction(function)» «ENDFOR» 
			«processFunction(p.main)»
			return 0;
		'''
	}

	def processFunction(Function function) {
		'''
			«IF function.returnType !==null» «function.returnType» «ELSE» void «ENDIF» «function.name» ( «IF !(function.params.isNullOrEmpty)» «processParameters(function.params)» «ENDIF» ) {
				«FOR variable : function.vars» «processVariable(variable)» «ENDFOR»
				«FOR statement : function.statements»«processStatement(statement)»«ENDFOR»
			}
		'''
	}

	def processVariable(Variable variable) {
		'''
			«variable.type» «variable.name» «IF variable.value !== null»= «processExpression(variable.value)»«ENDIF»;
		'''
	}

	def dispatch processStatement(IfStatement ifStatement) '''
		if ( «processExpression(ifStatement.condition)» ) {
		    «FOR variable : ifStatement.vars»«processVariable(variable)»«ENDFOR»
		    «FOR statement : ifStatement.statements»«processStatement(statement)»«ENDFOR»
		} «IF ifStatement.^else !== null»«processStatement(ifStatement.^else as ElseStatement)»«ENDIF»
	'''

	def dispatch processStatement(ElseStatement elseStatement) {
		'''
			else {
				«FOR variable : elseStatement.vars»«processVariable(variable)»«ENDFOR»
				«FOR statement : elseStatement.statements»«processStatement(statement)»«ENDFOR»
			}
		'''
	}

	def dispatch processStatement(Print printStatement) {
		'''
			cout<<«processExpression(printStatement.value)»
		'''
	}

	def dispatch processStatement(Input inputStatement) {
		'''
			«IF inputStatement.prompt !== null»cout<<«inputStatement.prompt»«ENDIF»
			cin>>«inputStatement.getVar()»
		'''
	}

	def dispatch processStatement(ForStatement forStatement) 
		'''
			for(«processVariable(forStatement.val1)»; abs(«forStatement.^var»-«forStatement.val2»; «forStatement.^var»)  {
				«FOR variable : forStatement.vars»«processVariable(variable)»«ENDFOR»
				«FOR statement : forStatement.statements»«processStatement(statement)»«ENDFOR»
			}
		'''
	

	def processParameters(EList<Parameter> params) {
		'''
			«FOR param : params»«param.type» «param.name»«IF !param.equals(params.last)», «ENDIF»«ENDFOR»
		'''
	}

	def dispatch processExpression(StringLiteral stringLiteral) {
		return stringLiteral.value
	}

	def dispatch processExpression(BooleanExpression booleanExpression) {
		return true
	}

	def dispatch processExpression(IntExpression intExpression) {
	}

	def processBooleanExpression(BooleanLiteral booleanLiteral) {
	}

}
