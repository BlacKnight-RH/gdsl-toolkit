/**
 */
package gdsl.plugin.gDSL.impl;

import gdsl.plugin.gDSL.*;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;

import org.eclipse.emf.ecore.impl.EFactoryImpl;

import org.eclipse.emf.ecore.plugin.EcorePlugin;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model <b>Factory</b>.
 * <!-- end-user-doc -->
 * @generated
 */
public class GDSLFactoryImpl extends EFactoryImpl implements GDSLFactory
{
  /**
   * Creates the default factory implementation.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public static GDSLFactory init()
  {
    try
    {
      GDSLFactory theGDSLFactory = (GDSLFactory)EPackage.Registry.INSTANCE.getEFactory(GDSLPackage.eNS_URI);
      if (theGDSLFactory != null)
      {
        return theGDSLFactory;
      }
    }
    catch (Exception exception)
    {
      EcorePlugin.INSTANCE.log(exception);
    }
    return new GDSLFactoryImpl();
  }

  /**
   * Creates an instance of the factory.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public GDSLFactoryImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public EObject create(EClass eClass)
  {
    switch (eClass.getClassifierID())
    {
      case GDSLPackage.MODEL: return createModel();
      case GDSLPackage.DECL: return createDecl();
      case GDSLPackage.DECL_GRANULARITY: return createDeclGranularity();
      case GDSLPackage.DECL_EXPORT: return createDeclExport();
      case GDSLPackage.DECL_TYPE: return createDeclType();
      case GDSLPackage.DECL_VAL: return createDeclVal();
      case GDSLPackage.EXPORT: return createExport();
      case GDSLPackage.CON_DECLS: return createConDecls();
      case GDSLPackage.CON_DECL: return createConDecl();
      case GDSLPackage.TY: return createTy();
      case GDSLPackage.TY_ELEMENT: return createTyElement();
      case GDSLPackage.TY_BIND: return createTyBind();
      case GDSLPackage.DECODE_PAT: return createDecodePat();
      case GDSLPackage.BIT_PAT: return createBitPat();
      case GDSLPackage.TOK_PAT: return createTokPat();
      case GDSLPackage.EXP: return createExp();
      case GDSLPackage.CASE_EXP: return createCaseExp();
      case GDSLPackage.CLOSED_EXP: return createClosedExp();
      case GDSLPackage.MONADIC_EXP: return createMonadicExp();
      case GDSLPackage.CASES: return createCases();
      case GDSLPackage.OR_ELSE_EXP: return createOrElseExp();
      case GDSLPackage.AND_ALSO_EXP: return createAndAlsoExp();
      case GDSLPackage.REXP: return createRExp();
      default:
        throw new IllegalArgumentException("The class '" + eClass.getName() + "' is not a valid classifier");
    }
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public Model createModel()
  {
    ModelImpl model = new ModelImpl();
    return model;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public Decl createDecl()
  {
    DeclImpl decl = new DeclImpl();
    return decl;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public DeclGranularity createDeclGranularity()
  {
    DeclGranularityImpl declGranularity = new DeclGranularityImpl();
    return declGranularity;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public DeclExport createDeclExport()
  {
    DeclExportImpl declExport = new DeclExportImpl();
    return declExport;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public DeclType createDeclType()
  {
    DeclTypeImpl declType = new DeclTypeImpl();
    return declType;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public DeclVal createDeclVal()
  {
    DeclValImpl declVal = new DeclValImpl();
    return declVal;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public Export createExport()
  {
    ExportImpl export = new ExportImpl();
    return export;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public ConDecls createConDecls()
  {
    ConDeclsImpl conDecls = new ConDeclsImpl();
    return conDecls;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public ConDecl createConDecl()
  {
    ConDeclImpl conDecl = new ConDeclImpl();
    return conDecl;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public Ty createTy()
  {
    TyImpl ty = new TyImpl();
    return ty;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public TyElement createTyElement()
  {
    TyElementImpl tyElement = new TyElementImpl();
    return tyElement;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public TyBind createTyBind()
  {
    TyBindImpl tyBind = new TyBindImpl();
    return tyBind;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public DecodePat createDecodePat()
  {
    DecodePatImpl decodePat = new DecodePatImpl();
    return decodePat;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public BitPat createBitPat()
  {
    BitPatImpl bitPat = new BitPatImpl();
    return bitPat;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public TokPat createTokPat()
  {
    TokPatImpl tokPat = new TokPatImpl();
    return tokPat;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public Exp createExp()
  {
    ExpImpl exp = new ExpImpl();
    return exp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public CaseExp createCaseExp()
  {
    CaseExpImpl caseExp = new CaseExpImpl();
    return caseExp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public ClosedExp createClosedExp()
  {
    ClosedExpImpl closedExp = new ClosedExpImpl();
    return closedExp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public MonadicExp createMonadicExp()
  {
    MonadicExpImpl monadicExp = new MonadicExpImpl();
    return monadicExp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public Cases createCases()
  {
    CasesImpl cases = new CasesImpl();
    return cases;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public OrElseExp createOrElseExp()
  {
    OrElseExpImpl orElseExp = new OrElseExpImpl();
    return orElseExp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public AndAlsoExp createAndAlsoExp()
  {
    AndAlsoExpImpl andAlsoExp = new AndAlsoExpImpl();
    return andAlsoExp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public RExp createRExp()
  {
    RExpImpl rExp = new RExpImpl();
    return rExp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public GDSLPackage getGDSLPackage()
  {
    return (GDSLPackage)getEPackage();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @deprecated
   * @generated
   */
  @Deprecated
  public static GDSLPackage getPackage()
  {
    return GDSLPackage.eINSTANCE;
  }

} //GDSLFactoryImpl
