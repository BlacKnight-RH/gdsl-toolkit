package gdsl.plugin.serializer;

import com.google.inject.Inject;
import com.google.inject.Provider;
import gdsl.plugin.gDSL.ConDecl;
import gdsl.plugin.gDSL.ConDecls;
import gdsl.plugin.gDSL.DeclExport;
import gdsl.plugin.gDSL.DeclGranularity;
import gdsl.plugin.gDSL.DeclType;
import gdsl.plugin.gDSL.DeclVal;
import gdsl.plugin.gDSL.Export;
import gdsl.plugin.gDSL.GDSLPackage;
import gdsl.plugin.gDSL.Model;
import gdsl.plugin.gDSL.Ty;
import gdsl.plugin.gDSL.TyBind;
import gdsl.plugin.gDSL.TyElement;
import gdsl.plugin.services.GDSLGrammarAccess;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.serializer.acceptor.ISemanticSequenceAcceptor;
import org.eclipse.xtext.serializer.acceptor.SequenceFeeder;
import org.eclipse.xtext.serializer.diagnostic.ISemanticSequencerDiagnosticProvider;
import org.eclipse.xtext.serializer.diagnostic.ISerializationDiagnostic.Acceptor;
import org.eclipse.xtext.serializer.sequencer.AbstractDelegatingSemanticSequencer;
import org.eclipse.xtext.serializer.sequencer.GenericSequencer;
import org.eclipse.xtext.serializer.sequencer.ISemanticNodeProvider.INodesForEObjectProvider;
import org.eclipse.xtext.serializer.sequencer.ISemanticSequencer;
import org.eclipse.xtext.serializer.sequencer.ITransientValueService;
import org.eclipse.xtext.serializer.sequencer.ITransientValueService.ValueTransient;

@SuppressWarnings("all")
public class GDSLSemanticSequencer extends AbstractDelegatingSemanticSequencer {

	@Inject
	private GDSLGrammarAccess grammarAccess;
	
	public void createSequence(EObject context, EObject semanticObject) {
		if(semanticObject.eClass().getEPackage() == GDSLPackage.eINSTANCE) switch(semanticObject.eClass().getClassifierID()) {
			case GDSLPackage.CON_DECL:
				if(context == grammarAccess.getConDeclRule()) {
					sequence_ConDecl(context, (ConDecl) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.CON_DECLS:
				if(context == grammarAccess.getConDeclsRule()) {
					sequence_ConDecls(context, (ConDecls) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.DECL_EXPORT:
				if(context == grammarAccess.getDeclRule() ||
				   context == grammarAccess.getDeclExportRule()) {
					sequence_DeclExport(context, (DeclExport) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.DECL_GRANULARITY:
				if(context == grammarAccess.getDeclRule() ||
				   context == grammarAccess.getDeclGranularityRule()) {
					sequence_DeclGranularity(context, (DeclGranularity) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.DECL_TYPE:
				if(context == grammarAccess.getDeclRule() ||
				   context == grammarAccess.getDeclTypeRule()) {
					sequence_DeclType(context, (DeclType) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.DECL_VAL:
				if(context == grammarAccess.getDeclRule() ||
				   context == grammarAccess.getDeclValRule()) {
					sequence_DeclVal(context, (DeclVal) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.EXPORT:
				if(context == grammarAccess.getExportRule()) {
					sequence_Export(context, (Export) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.MODEL:
				if(context == grammarAccess.getModelRule()) {
					sequence_Model(context, (Model) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.TY:
				if(context == grammarAccess.getTyRule()) {
					sequence_Ty(context, (Ty) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.TY_BIND:
				if(context == grammarAccess.getTyBindRule()) {
					sequence_TyBind(context, (TyBind) semanticObject); 
					return; 
				}
				else break;
			case GDSLPackage.TY_ELEMENT:
				if(context == grammarAccess.getTyElementRule()) {
					sequence_TyElement(context, (TyElement) semanticObject); 
					return; 
				}
				else break;
			}
		if (errorAcceptor != null) errorAcceptor.accept(diagnosticProvider.createInvalidContextOrTypeDiagnostic(semanticObject, context));
	}
	
	/**
	 * Constraint:
	 *     (name=ConBind ty=Ty?)
	 */
	protected void sequence_ConDecl(EObject context, ConDecl semanticObject) {
		genericSequencer.createSequence(context, semanticObject);
	}
	
	
	/**
	 * Constraint:
	 *     (conDecls+=ConDecl conDecls+=ConDecl*)
	 */
	protected void sequence_ConDecls(EObject context, ConDecls semanticObject) {
		genericSequencer.createSequence(context, semanticObject);
	}
	
	
	/**
	 * Constraint:
	 *     (name='export' exports+=Export*)
	 */
	protected void sequence_DeclExport(EObject context, DeclExport semanticObject) {
		genericSequencer.createSequence(context, semanticObject);
	}
	
	
	/**
	 * Constraint:
	 *     (name='granularity' granularity=Int)
	 */
	protected void sequence_DeclGranularity(EObject context, DeclGranularity semanticObject) {
		if(errorAcceptor != null) {
			if(transientValues.isValueTransient(semanticObject, GDSLPackage.Literals.DECL__NAME) == ValueTransient.YES)
				errorAcceptor.accept(diagnosticProvider.createFeatureValueMissing(semanticObject, GDSLPackage.Literals.DECL__NAME));
			if(transientValues.isValueTransient(semanticObject, GDSLPackage.Literals.DECL_GRANULARITY__GRANULARITY) == ValueTransient.YES)
				errorAcceptor.accept(diagnosticProvider.createFeatureValueMissing(semanticObject, GDSLPackage.Literals.DECL_GRANULARITY__GRANULARITY));
		}
		INodesForEObjectProvider nodes = createNodeProvider(semanticObject);
		SequenceFeeder feeder = createSequencerFeeder(semanticObject, nodes);
		feeder.accept(grammarAccess.getDeclGranularityAccess().getNameGranularityKeyword_0_0(), semanticObject.getName());
		feeder.accept(grammarAccess.getDeclGranularityAccess().getGranularityIntParserRuleCall_2_0(), semanticObject.getGranularity());
		feeder.finish();
	}
	
	
	/**
	 * Constraint:
	 *     ((name=ID (value=ConDecls | value=Ty)) | (name=ID attrName+=ID attrName+=ID* value=ConDecls))
	 */
	protected void sequence_DeclType(EObject context, DeclType semanticObject) {
		genericSequencer.createSequence(context, semanticObject);
	}
	
	
	/**
	 * Constraint:
	 *     (name=ID attr+=ID*)
	 */
	protected void sequence_DeclVal(EObject context, DeclVal semanticObject) {
		genericSequencer.createSequence(context, semanticObject);
	}
	
	
	/**
	 * Constraint:
	 *     (name=Qid (attrName+=ID attrName+=ID*)?)
	 */
	protected void sequence_Export(EObject context, Export semanticObject) {
		genericSequencer.createSequence(context, semanticObject);
	}
	
	
	/**
	 * Constraint:
	 *     (decl+=Decl decl+=Decl*)
	 */
	protected void sequence_Model(EObject context, Model semanticObject) {
		genericSequencer.createSequence(context, semanticObject);
	}
	
	
	/**
	 * Constraint:
	 *     (key=Qid value=Ty?)
	 */
	protected void sequence_TyBind(EObject context, TyBind semanticObject) {
		genericSequencer.createSequence(context, semanticObject);
	}
	
	
	/**
	 * Constraint:
	 *     (name=ID value=Ty)
	 */
	protected void sequence_TyElement(EObject context, TyElement semanticObject) {
		if(errorAcceptor != null) {
			if(transientValues.isValueTransient(semanticObject, GDSLPackage.Literals.TY_ELEMENT__NAME) == ValueTransient.YES)
				errorAcceptor.accept(diagnosticProvider.createFeatureValueMissing(semanticObject, GDSLPackage.Literals.TY_ELEMENT__NAME));
			if(transientValues.isValueTransient(semanticObject, GDSLPackage.Literals.TY_ELEMENT__VALUE) == ValueTransient.YES)
				errorAcceptor.accept(diagnosticProvider.createFeatureValueMissing(semanticObject, GDSLPackage.Literals.TY_ELEMENT__VALUE));
		}
		INodesForEObjectProvider nodes = createNodeProvider(semanticObject);
		SequenceFeeder feeder = createSequencerFeeder(semanticObject, nodes);
		feeder.accept(grammarAccess.getTyElementAccess().getNameIDTerminalRuleCall_0_0(), semanticObject.getName());
		feeder.accept(grammarAccess.getTyElementAccess().getValueTyParserRuleCall_2_0(), semanticObject.getValue());
		feeder.finish();
	}
	
	
	/**
	 * Constraint:
	 *     (value=Int | value=Int | (value=Qid (tyBind+=TyBind tyBind+=TyBind*)?) | (elements+=TyElement elements+=TyElement*))
	 */
	protected void sequence_Ty(EObject context, Ty semanticObject) {
		genericSequencer.createSequence(context, semanticObject);
	}
}