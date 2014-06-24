/*
* generated by Xtext
*/
package gdsl.plugin.ui.contentassist.antlr;

import java.util.Collection;
import java.util.Map;
import java.util.HashMap;

import org.antlr.runtime.RecognitionException;
import org.eclipse.xtext.AbstractElement;
import org.eclipse.xtext.ui.editor.contentassist.antlr.AbstractContentAssistParser;
import org.eclipse.xtext.ui.editor.contentassist.antlr.FollowElement;
import org.eclipse.xtext.ui.editor.contentassist.antlr.internal.AbstractInternalContentAssistParser;

import com.google.inject.Inject;

import gdsl.plugin.services.GDSLGrammarAccess;

public class GDSLParser extends AbstractContentAssistParser {
	
	@Inject
	private GDSLGrammarAccess grammarAccess;
	
	private Map<AbstractElement, String> nameMappings;
	
	@Override
	protected gdsl.plugin.ui.contentassist.antlr.internal.InternalGDSLParser createParser() {
		gdsl.plugin.ui.contentassist.antlr.internal.InternalGDSLParser result = new gdsl.plugin.ui.contentassist.antlr.internal.InternalGDSLParser(null);
		result.setGrammarAccess(grammarAccess);
		return result;
	}
	
	@Override
	protected String getRuleName(AbstractElement element) {
		if (nameMappings == null) {
			nameMappings = new HashMap<AbstractElement, String>() {
				private static final long serialVersionUID = 1L;
				{
					put(grammarAccess.getDeclAccess().getAlternatives(), "rule__Decl__Alternatives");
					put(grammarAccess.getDeclTypeAccess().getAlternatives_2(), "rule__DeclType__Alternatives_2");
					put(grammarAccess.getDeclTypeAccess().getAlternatives_2_0(), "rule__DeclType__Alternatives_2_0");
					put(grammarAccess.getDeclValAccess().getAlternatives(), "rule__DeclVal__Alternatives");
					put(grammarAccess.getDeclValAccess().getAlternatives_0_1(), "rule__DeclVal__Alternatives_0_1");
					put(grammarAccess.getDeclValAccess().getAlternatives_2_5(), "rule__DeclVal__Alternatives_2_5");
					put(grammarAccess.getTyAccess().getAlternatives(), "rule__Ty__Alternatives");
					put(grammarAccess.getDecodePatAccess().getAlternatives(), "rule__DecodePat__Alternatives");
					put(grammarAccess.getTokPatAccess().getTokPatAlternatives_0(), "rule__TokPat__TokPatAlternatives_0");
					put(grammarAccess.getExpAccess().getAlternatives(), "rule__Exp__Alternatives");
					put(grammarAccess.getCaseExpAccess().getAlternatives(), "rule__CaseExp__Alternatives");
					put(grammarAccess.getClosedExpAccess().getAlternatives(), "rule__ClosedExp__Alternatives");
					put(grammarAccess.getMonadicExpAccess().getAlternatives(), "rule__MonadicExp__Alternatives");
					put(grammarAccess.getAExpAccess().getSignAlternatives_1_0_0(), "rule__AExp__SignAlternatives_1_0_0");
					put(grammarAccess.getAtomicExpAccess().getAlternatives(), "rule__AtomicExp__Alternatives");
					put(grammarAccess.getFieldAccess().getAlternatives(), "rule__Field__Alternatives");
					put(grammarAccess.getPatAccess().getAlternatives(), "rule__Pat__Alternatives");
					put(grammarAccess.getLitAccess().getAlternatives(), "rule__Lit__Alternatives");
					put(grammarAccess.getPrimBitPatAccess().getAlternatives(), "rule__PrimBitPat__Alternatives");
					put(grammarAccess.getBitPatOrIntAccess().getAlternatives(), "rule__BitPatOrInt__Alternatives");
					put(grammarAccess.getIntAccess().getAlternatives(), "rule__Int__Alternatives");
					put(grammarAccess.getPOSINTAccess().getAlternatives(), "rule__POSINT__Alternatives");
					put(grammarAccess.getHEXDIGITAccess().getAlternatives(), "rule__HEXDIGIT__Alternatives");
					put(grammarAccess.getHEXCHARAccess().getAlternatives(), "rule__HEXCHAR__Alternatives");
					put(grammarAccess.getULETTERAccess().getAlternatives(), "rule__ULETTER__Alternatives");
					put(grammarAccess.getLETTERAccess().getAlternatives(), "rule__LETTER__Alternatives");
					put(grammarAccess.getIDCHARAccess().getAlternatives(), "rule__IDCHAR__Alternatives");
					put(grammarAccess.getBINARYAccess().getAlternatives(), "rule__BINARY__Alternatives");
					put(grammarAccess.getDIGAccess().getAlternatives(), "rule__DIG__Alternatives");
					put(grammarAccess.getSYMAccess().getAlternatives(), "rule__SYM__Alternatives");
					put(grammarAccess.getModelAccess().getGroup(), "rule__Model__Group__0");
					put(grammarAccess.getModelAccess().getGroup_1(), "rule__Model__Group_1__0");
					put(grammarAccess.getDeclGranularityAccess().getGroup(), "rule__DeclGranularity__Group__0");
					put(grammarAccess.getDeclExportAccess().getGroup(), "rule__DeclExport__Group__0");
					put(grammarAccess.getDeclTypeAccess().getGroup(), "rule__DeclType__Group__0");
					put(grammarAccess.getDeclTypeAccess().getGroup_2_0_0(), "rule__DeclType__Group_2_0_0__0");
					put(grammarAccess.getDeclTypeAccess().getGroup_2_1(), "rule__DeclType__Group_2_1__0");
					put(grammarAccess.getDeclTypeAccess().getGroup_2_1_2(), "rule__DeclType__Group_2_1_2__0");
					put(grammarAccess.getDeclValAccess().getGroup_0(), "rule__DeclVal__Group_0__0");
					put(grammarAccess.getDeclValAccess().getGroup_1(), "rule__DeclVal__Group_1__0");
					put(grammarAccess.getDeclValAccess().getGroup_1_1(), "rule__DeclVal__Group_1_1__0");
					put(grammarAccess.getDeclValAccess().getGroup_2(), "rule__DeclVal__Group_2__0");
					put(grammarAccess.getDeclValAccess().getGroup_2_3(), "rule__DeclVal__Group_2_3__0");
					put(grammarAccess.getDeclValAccess().getGroup_2_5_0(), "rule__DeclVal__Group_2_5_0__0");
					put(grammarAccess.getDeclValAccess().getGroup_2_5_1(), "rule__DeclVal__Group_2_5_1__0");
					put(grammarAccess.getExportAccess().getGroup(), "rule__Export__Group__0");
					put(grammarAccess.getExportAccess().getGroup_1(), "rule__Export__Group_1__0");
					put(grammarAccess.getExportAccess().getGroup_1_2(), "rule__Export__Group_1_2__0");
					put(grammarAccess.getConDeclsAccess().getGroup(), "rule__ConDecls__Group__0");
					put(grammarAccess.getConDeclsAccess().getGroup_1(), "rule__ConDecls__Group_1__0");
					put(grammarAccess.getConDeclAccess().getGroup(), "rule__ConDecl__Group__0");
					put(grammarAccess.getConDeclAccess().getGroup_1(), "rule__ConDecl__Group_1__0");
					put(grammarAccess.getTyAccess().getGroup_1(), "rule__Ty__Group_1__0");
					put(grammarAccess.getTyAccess().getGroup_2(), "rule__Ty__Group_2__0");
					put(grammarAccess.getTyAccess().getGroup_2_1(), "rule__Ty__Group_2_1__0");
					put(grammarAccess.getTyAccess().getGroup_2_1_2(), "rule__Ty__Group_2_1_2__0");
					put(grammarAccess.getTyAccess().getGroup_3(), "rule__Ty__Group_3__0");
					put(grammarAccess.getTyAccess().getGroup_3_2(), "rule__Ty__Group_3_2__0");
					put(grammarAccess.getTyElementAccess().getGroup(), "rule__TyElement__Group__0");
					put(grammarAccess.getTyBindAccess().getGroup(), "rule__TyBind__Group__0");
					put(grammarAccess.getTyBindAccess().getGroup_1(), "rule__TyBind__Group_1__0");
					put(grammarAccess.getBitPatAccess().getGroup(), "rule__BitPat__Group__0");
					put(grammarAccess.getExpAccess().getGroup_1(), "rule__Exp__Group_1__0");
					put(grammarAccess.getCaseExpAccess().getGroup_1(), "rule__CaseExp__Group_1__0");
					put(grammarAccess.getClosedExpAccess().getGroup_1(), "rule__ClosedExp__Group_1__0");
					put(grammarAccess.getClosedExpAccess().getGroup_2(), "rule__ClosedExp__Group_2__0");
					put(grammarAccess.getClosedExpAccess().getGroup_2_2(), "rule__ClosedExp__Group_2_2__0");
					put(grammarAccess.getMonadicExpAccess().getGroup_1(), "rule__MonadicExp__Group_1__0");
					put(grammarAccess.getCasesAccess().getGroup(), "rule__Cases__Group__0");
					put(grammarAccess.getCasesAccess().getGroup_3(), "rule__Cases__Group_3__0");
					put(grammarAccess.getOrElseExpAccess().getGroup(), "rule__OrElseExp__Group__0");
					put(grammarAccess.getOrElseExpAccess().getGroup_1(), "rule__OrElseExp__Group_1__0");
					put(grammarAccess.getAndAlsoExpAccess().getGroup(), "rule__AndAlsoExp__Group__0");
					put(grammarAccess.getAndAlsoExpAccess().getGroup_1(), "rule__AndAlsoExp__Group_1__0");
					put(grammarAccess.getRExpAccess().getGroup(), "rule__RExp__Group__0");
					put(grammarAccess.getRExpAccess().getGroup_1(), "rule__RExp__Group_1__0");
					put(grammarAccess.getAExpAccess().getGroup(), "rule__AExp__Group__0");
					put(grammarAccess.getAExpAccess().getGroup_1(), "rule__AExp__Group_1__0");
					put(grammarAccess.getMExpAccess().getGroup(), "rule__MExp__Group__0");
					put(grammarAccess.getMExpAccess().getGroup_1(), "rule__MExp__Group_1__0");
					put(grammarAccess.getApplyExpAccess().getGroup(), "rule__ApplyExp__Group__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_0(), "rule__AtomicExp__Group_0__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_1(), "rule__AtomicExp__Group_1__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_2(), "rule__AtomicExp__Group_2__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_2_1(), "rule__AtomicExp__Group_2_1__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_3(), "rule__AtomicExp__Group_3__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_4(), "rule__AtomicExp__Group_4__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_4_3(), "rule__AtomicExp__Group_4_3__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_5(), "rule__AtomicExp__Group_5__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_6(), "rule__AtomicExp__Group_6__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_6_3(), "rule__AtomicExp__Group_6_3__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_7(), "rule__AtomicExp__Group_7__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_7_2(), "rule__AtomicExp__Group_7_2__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_7_2_3(), "rule__AtomicExp__Group_7_2_3__0");
					put(grammarAccess.getAtomicExpAccess().getGroup_8(), "rule__AtomicExp__Group_8__0");
					put(grammarAccess.getFieldAccess().getGroup_0(), "rule__Field__Group_0__0");
					put(grammarAccess.getFieldAccess().getGroup_1(), "rule__Field__Group_1__0");
					put(grammarAccess.getValueDeclAccess().getGroup(), "rule__ValueDecl__Group__0");
					put(grammarAccess.getStringAccess().getGroup(), "rule__String__Group__0");
					put(grammarAccess.getPatAccess().getGroup_3(), "rule__Pat__Group_3__0");
					put(grammarAccess.getLitAccess().getGroup_1(), "rule__Lit__Group_1__0");
					put(grammarAccess.getPrimBitPatAccess().getGroup_1(), "rule__PrimBitPat__Group_1__0");
					put(grammarAccess.getBitPatOrIntAccess().getGroup_0(), "rule__BitPatOrInt__Group_0__0");
					put(grammarAccess.getBitPatOrIntAccess().getGroup_1(), "rule__BitPatOrInt__Group_1__0");
					put(grammarAccess.getNEGINTAccess().getGroup(), "rule__NEGINT__Group__0");
					put(grammarAccess.getHEXNUMAccess().getGroup(), "rule__HEXNUM__Group__0");
					put(grammarAccess.getMIXIDAccess().getGroup(), "rule__MIXID__Group__0");
					put(grammarAccess.getCONSAccess().getGroup(), "rule__CONS__Group__0");
					put(grammarAccess.getIDAccess().getGroup(), "rule__ID__Group__0");
					put(grammarAccess.getModelAccess().getDeclAssignment_0(), "rule__Model__DeclAssignment_0");
					put(grammarAccess.getModelAccess().getDeclAssignment_1_1(), "rule__Model__DeclAssignment_1_1");
					put(grammarAccess.getDeclGranularityAccess().getNameAssignment_0(), "rule__DeclGranularity__NameAssignment_0");
					put(grammarAccess.getDeclGranularityAccess().getGranularityAssignment_2(), "rule__DeclGranularity__GranularityAssignment_2");
					put(grammarAccess.getDeclExportAccess().getNameAssignment_0(), "rule__DeclExport__NameAssignment_0");
					put(grammarAccess.getDeclExportAccess().getExportsAssignment_2(), "rule__DeclExport__ExportsAssignment_2");
					put(grammarAccess.getDeclTypeAccess().getNameAssignment_1(), "rule__DeclType__NameAssignment_1");
					put(grammarAccess.getDeclTypeAccess().getValueAssignment_2_0_0_1(), "rule__DeclType__ValueAssignment_2_0_0_1");
					put(grammarAccess.getDeclTypeAccess().getValueAssignment_2_0_1(), "rule__DeclType__ValueAssignment_2_0_1");
					put(grammarAccess.getDeclTypeAccess().getAttrNameAssignment_2_1_1(), "rule__DeclType__AttrNameAssignment_2_1_1");
					put(grammarAccess.getDeclTypeAccess().getAttrNameAssignment_2_1_2_1(), "rule__DeclType__AttrNameAssignment_2_1_2_1");
					put(grammarAccess.getDeclTypeAccess().getValueAssignment_2_1_5(), "rule__DeclType__ValueAssignment_2_1_5");
					put(grammarAccess.getDeclValAccess().getNameAssignment_0_1_0(), "rule__DeclVal__NameAssignment_0_1_0");
					put(grammarAccess.getDeclValAccess().getNameAssignment_0_1_1(), "rule__DeclVal__NameAssignment_0_1_1");
					put(grammarAccess.getDeclValAccess().getAttrAssignment_0_2(), "rule__DeclVal__AttrAssignment_0_2");
					put(grammarAccess.getDeclValAccess().getExpAssignment_0_4(), "rule__DeclVal__ExpAssignment_0_4");
					put(grammarAccess.getDeclValAccess().getMidAssignment_1_1_0(), "rule__DeclVal__MidAssignment_1_1_0");
					put(grammarAccess.getDeclValAccess().getAttrAssignment_1_1_1(), "rule__DeclVal__AttrAssignment_1_1_1");
					put(grammarAccess.getDeclValAccess().getExpAssignment_1_3(), "rule__DeclVal__ExpAssignment_1_3");
					put(grammarAccess.getDeclValAccess().getNameAssignment_2_1(), "rule__DeclVal__NameAssignment_2_1");
					put(grammarAccess.getDeclValAccess().getDecPatAssignment_2_3_0(), "rule__DeclVal__DecPatAssignment_2_3_0");
					put(grammarAccess.getDeclValAccess().getDecPatAssignment_2_3_1(), "rule__DeclVal__DecPatAssignment_2_3_1");
					put(grammarAccess.getDeclValAccess().getExpAssignment_2_5_0_1(), "rule__DeclVal__ExpAssignment_2_5_0_1");
					put(grammarAccess.getDeclValAccess().getExpsAssignment_2_5_1_1(), "rule__DeclVal__ExpsAssignment_2_5_1_1");
					put(grammarAccess.getDeclValAccess().getExpsAssignment_2_5_1_3(), "rule__DeclVal__ExpsAssignment_2_5_1_3");
					put(grammarAccess.getExportAccess().getNameAssignment_0(), "rule__Export__NameAssignment_0");
					put(grammarAccess.getExportAccess().getAttrNameAssignment_1_1(), "rule__Export__AttrNameAssignment_1_1");
					put(grammarAccess.getExportAccess().getAttrNameAssignment_1_2_1(), "rule__Export__AttrNameAssignment_1_2_1");
					put(grammarAccess.getConDeclsAccess().getConDeclsAssignment_0(), "rule__ConDecls__ConDeclsAssignment_0");
					put(grammarAccess.getConDeclsAccess().getConDeclsAssignment_1_1(), "rule__ConDecls__ConDeclsAssignment_1_1");
					put(grammarAccess.getConDeclAccess().getNameAssignment_0(), "rule__ConDecl__NameAssignment_0");
					put(grammarAccess.getConDeclAccess().getTyAssignment_1_1(), "rule__ConDecl__TyAssignment_1_1");
					put(grammarAccess.getTyAccess().getValueAssignment_0(), "rule__Ty__ValueAssignment_0");
					put(grammarAccess.getTyAccess().getValueAssignment_1_1(), "rule__Ty__ValueAssignment_1_1");
					put(grammarAccess.getTyAccess().getValueAssignment_2_0(), "rule__Ty__ValueAssignment_2_0");
					put(grammarAccess.getTyAccess().getTyBindAssignment_2_1_1(), "rule__Ty__TyBindAssignment_2_1_1");
					put(grammarAccess.getTyAccess().getTyBindAssignment_2_1_2_1(), "rule__Ty__TyBindAssignment_2_1_2_1");
					put(grammarAccess.getTyAccess().getElementsAssignment_3_1(), "rule__Ty__ElementsAssignment_3_1");
					put(grammarAccess.getTyAccess().getElementsAssignment_3_2_1(), "rule__Ty__ElementsAssignment_3_2_1");
					put(grammarAccess.getTyElementAccess().getNameAssignment_0(), "rule__TyElement__NameAssignment_0");
					put(grammarAccess.getTyElementAccess().getValueAssignment_2(), "rule__TyElement__ValueAssignment_2");
					put(grammarAccess.getTyBindAccess().getKeyAssignment_0(), "rule__TyBind__KeyAssignment_0");
					put(grammarAccess.getTyBindAccess().getValueAssignment_1_1(), "rule__TyBind__ValueAssignment_1_1");
					put(grammarAccess.getBitPatAccess().getBitpatAssignment_1(), "rule__BitPat__BitpatAssignment_1");
					put(grammarAccess.getBitPatAccess().getBitpatAssignment_2(), "rule__BitPat__BitpatAssignment_2");
					put(grammarAccess.getTokPatAccess().getTokPatAssignment(), "rule__TokPat__TokPatAssignment");
					put(grammarAccess.getExpAccess().getCaseExpAssignment_0(), "rule__Exp__CaseExpAssignment_0");
					put(grammarAccess.getExpAccess().getMidAssignment_1_0(), "rule__Exp__MidAssignment_1_0");
					put(grammarAccess.getExpAccess().getCaseExpAssignment_1_1(), "rule__Exp__CaseExpAssignment_1_1");
					put(grammarAccess.getCaseExpAccess().getClosedExpAssignment_1_1(), "rule__CaseExp__ClosedExpAssignment_1_1");
					put(grammarAccess.getCaseExpAccess().getCasesAssignment_1_3(), "rule__CaseExp__CasesAssignment_1_3");
					put(grammarAccess.getClosedExpAccess().getIfCaseExpAssignment_1_1(), "rule__ClosedExp__IfCaseExpAssignment_1_1");
					put(grammarAccess.getClosedExpAccess().getThenCaseExpAssignment_1_3(), "rule__ClosedExp__ThenCaseExpAssignment_1_3");
					put(grammarAccess.getClosedExpAccess().getElseCaseExpAssignment_1_5(), "rule__ClosedExp__ElseCaseExpAssignment_1_5");
					put(grammarAccess.getClosedExpAccess().getDoExpAssignment_2_1(), "rule__ClosedExp__DoExpAssignment_2_1");
					put(grammarAccess.getClosedExpAccess().getDoExpAssignment_2_2_1(), "rule__ClosedExp__DoExpAssignment_2_2_1");
					put(grammarAccess.getMonadicExpAccess().getExpAssignment_0(), "rule__MonadicExp__ExpAssignment_0");
					put(grammarAccess.getMonadicExpAccess().getNameAssignment_1_0(), "rule__MonadicExp__NameAssignment_1_0");
					put(grammarAccess.getMonadicExpAccess().getExpAssignment_1_2(), "rule__MonadicExp__ExpAssignment_1_2");
					put(grammarAccess.getCasesAccess().getPatAssignment_0(), "rule__Cases__PatAssignment_0");
					put(grammarAccess.getCasesAccess().getExpAssignment_2(), "rule__Cases__ExpAssignment_2");
					put(grammarAccess.getCasesAccess().getPatAssignment_3_1(), "rule__Cases__PatAssignment_3_1");
					put(grammarAccess.getCasesAccess().getExpAssignment_3_3(), "rule__Cases__ExpAssignment_3_3");
					put(grammarAccess.getOrElseExpAccess().getRightAssignment_1_2(), "rule__OrElseExp__RightAssignment_1_2");
					put(grammarAccess.getAndAlsoExpAccess().getRightAssignment_1_2(), "rule__AndAlsoExp__RightAssignment_1_2");
					put(grammarAccess.getRExpAccess().getAexpAssignment_0(), "rule__RExp__AexpAssignment_0");
					put(grammarAccess.getRExpAccess().getSymAssignment_1_0(), "rule__RExp__SymAssignment_1_0");
					put(grammarAccess.getRExpAccess().getAexpsAssignment_1_1(), "rule__RExp__AexpsAssignment_1_1");
					put(grammarAccess.getAExpAccess().getMexpAssignment_0(), "rule__AExp__MexpAssignment_0");
					put(grammarAccess.getAExpAccess().getSignAssignment_1_0(), "rule__AExp__SignAssignment_1_0");
					put(grammarAccess.getAExpAccess().getMexpsAssignment_1_1(), "rule__AExp__MexpsAssignment_1_1");
					put(grammarAccess.getMExpAccess().getApplyexpsAssignment_0(), "rule__MExp__ApplyexpsAssignment_0");
					put(grammarAccess.getMExpAccess().getApplyexpsAssignment_1_1(), "rule__MExp__ApplyexpsAssignment_1_1");
					put(grammarAccess.getApplyExpAccess().getNegAssignment_0(), "rule__ApplyExp__NegAssignment_0");
					put(grammarAccess.getApplyExpAccess().getExpAssignment_1(), "rule__ApplyExp__ExpAssignment_1");
					put(grammarAccess.getAtomicExpAccess().getIdAssignment_2_0(), "rule__AtomicExp__IdAssignment_2_0");
					put(grammarAccess.getAtomicExpAccess().getIdAssignment_2_1_1(), "rule__AtomicExp__IdAssignment_2_1_1");
					put(grammarAccess.getAtomicExpAccess().getFieldsAssignment_4_2(), "rule__AtomicExp__FieldsAssignment_4_2");
					put(grammarAccess.getAtomicExpAccess().getFieldsAssignment_4_3_1(), "rule__AtomicExp__FieldsAssignment_4_3_1");
					put(grammarAccess.getAtomicExpAccess().getExpAssignment_6_1(), "rule__AtomicExp__ExpAssignment_6_1");
					put(grammarAccess.getAtomicExpAccess().getIdAssignment_6_3_1(), "rule__AtomicExp__IdAssignment_6_3_1");
					put(grammarAccess.getAtomicExpAccess().getIdAssignment_7_2_0(), "rule__AtomicExp__IdAssignment_7_2_0");
					put(grammarAccess.getAtomicExpAccess().getExpsAssignment_7_2_2(), "rule__AtomicExp__ExpsAssignment_7_2_2");
					put(grammarAccess.getAtomicExpAccess().getIdAssignment_7_2_3_0(), "rule__AtomicExp__IdAssignment_7_2_3_0");
					put(grammarAccess.getAtomicExpAccess().getExpsAssignment_7_2_3_2(), "rule__AtomicExp__ExpsAssignment_7_2_3_2");
					put(grammarAccess.getAtomicExpAccess().getValDeclAssignment_8_1(), "rule__AtomicExp__ValDeclAssignment_8_1");
					put(grammarAccess.getAtomicExpAccess().getExpAssignment_8_3(), "rule__AtomicExp__ExpAssignment_8_3");
					put(grammarAccess.getFieldAccess().getNameAssignment_0_0(), "rule__Field__NameAssignment_0_0");
					put(grammarAccess.getFieldAccess().getExpAssignment_0_2(), "rule__Field__ExpAssignment_0_2");
					put(grammarAccess.getFieldAccess().getNameAssignment_1_1(), "rule__Field__NameAssignment_1_1");
				}
			};
		}
		return nameMappings.get(element);
	}
	
	@Override
	protected Collection<FollowElement> getFollowElements(AbstractInternalContentAssistParser parser) {
		try {
			gdsl.plugin.ui.contentassist.antlr.internal.InternalGDSLParser typedParser = (gdsl.plugin.ui.contentassist.antlr.internal.InternalGDSLParser) parser;
			typedParser.entryRuleModel();
			return typedParser.getFollowElements();
		} catch(RecognitionException ex) {
			throw new RuntimeException(ex);
		}		
	}
	
	@Override
	protected String[] getInitialHiddenTokens() {
		return new String[] { "RULE_WS", "RULE_ML_COMMENT", "RULE_SL_COMMENT" };
	}
	
	public GDSLGrammarAccess getGrammarAccess() {
		return this.grammarAccess;
	}
	
	public void setGrammarAccess(GDSLGrammarAccess grammarAccess) {
		this.grammarAccess = grammarAccess;
	}
}
