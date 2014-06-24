/**
 */
package gdsl.plugin.gDSL.impl;

import gdsl.plugin.gDSL.AExp;
import gdsl.plugin.gDSL.GDSLPackage;
import gdsl.plugin.gDSL.RExp;

import java.util.Collection;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.NotificationChain;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;

import org.eclipse.emf.ecore.util.EDataTypeEList;
import org.eclipse.emf.ecore.util.EObjectContainmentEList;
import org.eclipse.emf.ecore.util.InternalEList;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>RExp</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * <ul>
 *   <li>{@link gdsl.plugin.gDSL.impl.RExpImpl#getAexp <em>Aexp</em>}</li>
 *   <li>{@link gdsl.plugin.gDSL.impl.RExpImpl#getSym <em>Sym</em>}</li>
 *   <li>{@link gdsl.plugin.gDSL.impl.RExpImpl#getAexps <em>Aexps</em>}</li>
 * </ul>
 * </p>
 *
 * @generated
 */
public class RExpImpl extends AndAlsoExpImpl implements RExp
{
  /**
   * The cached value of the '{@link #getAexp() <em>Aexp</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getAexp()
   * @generated
   * @ordered
   */
  protected AExp aexp;

  /**
   * The cached value of the '{@link #getSym() <em>Sym</em>}' attribute list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getSym()
   * @generated
   * @ordered
   */
  protected EList<String> sym;

  /**
   * The cached value of the '{@link #getAexps() <em>Aexps</em>}' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getAexps()
   * @generated
   * @ordered
   */
  protected EList<AExp> aexps;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected RExpImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass()
  {
    return GDSLPackage.Literals.REXP;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public AExp getAexp()
  {
    return aexp;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NotificationChain basicSetAexp(AExp newAexp, NotificationChain msgs)
  {
    AExp oldAexp = aexp;
    aexp = newAexp;
    if (eNotificationRequired())
    {
      ENotificationImpl notification = new ENotificationImpl(this, Notification.SET, GDSLPackage.REXP__AEXP, oldAexp, newAexp);
      if (msgs == null) msgs = notification; else msgs.add(notification);
    }
    return msgs;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public void setAexp(AExp newAexp)
  {
    if (newAexp != aexp)
    {
      NotificationChain msgs = null;
      if (aexp != null)
        msgs = ((InternalEObject)aexp).eInverseRemove(this, EOPPOSITE_FEATURE_BASE - GDSLPackage.REXP__AEXP, null, msgs);
      if (newAexp != null)
        msgs = ((InternalEObject)newAexp).eInverseAdd(this, EOPPOSITE_FEATURE_BASE - GDSLPackage.REXP__AEXP, null, msgs);
      msgs = basicSetAexp(newAexp, msgs);
      if (msgs != null) msgs.dispatch();
    }
    else if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, GDSLPackage.REXP__AEXP, newAexp, newAexp));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public EList<String> getSym()
  {
    if (sym == null)
    {
      sym = new EDataTypeEList<String>(String.class, this, GDSLPackage.REXP__SYM);
    }
    return sym;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public EList<AExp> getAexps()
  {
    if (aexps == null)
    {
      aexps = new EObjectContainmentEList<AExp>(AExp.class, this, GDSLPackage.REXP__AEXPS);
    }
    return aexps;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public NotificationChain eInverseRemove(InternalEObject otherEnd, int featureID, NotificationChain msgs)
  {
    switch (featureID)
    {
      case GDSLPackage.REXP__AEXP:
        return basicSetAexp(null, msgs);
      case GDSLPackage.REXP__AEXPS:
        return ((InternalEList<?>)getAexps()).basicRemove(otherEnd, msgs);
    }
    return super.eInverseRemove(otherEnd, featureID, msgs);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType)
  {
    switch (featureID)
    {
      case GDSLPackage.REXP__AEXP:
        return getAexp();
      case GDSLPackage.REXP__SYM:
        return getSym();
      case GDSLPackage.REXP__AEXPS:
        return getAexps();
    }
    return super.eGet(featureID, resolve, coreType);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @SuppressWarnings("unchecked")
  @Override
  public void eSet(int featureID, Object newValue)
  {
    switch (featureID)
    {
      case GDSLPackage.REXP__AEXP:
        setAexp((AExp)newValue);
        return;
      case GDSLPackage.REXP__SYM:
        getSym().clear();
        getSym().addAll((Collection<? extends String>)newValue);
        return;
      case GDSLPackage.REXP__AEXPS:
        getAexps().clear();
        getAexps().addAll((Collection<? extends AExp>)newValue);
        return;
    }
    super.eSet(featureID, newValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eUnset(int featureID)
  {
    switch (featureID)
    {
      case GDSLPackage.REXP__AEXP:
        setAexp((AExp)null);
        return;
      case GDSLPackage.REXP__SYM:
        getSym().clear();
        return;
      case GDSLPackage.REXP__AEXPS:
        getAexps().clear();
        return;
    }
    super.eUnset(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public boolean eIsSet(int featureID)
  {
    switch (featureID)
    {
      case GDSLPackage.REXP__AEXP:
        return aexp != null;
      case GDSLPackage.REXP__SYM:
        return sym != null && !sym.isEmpty();
      case GDSLPackage.REXP__AEXPS:
        return aexps != null && !aexps.isEmpty();
    }
    return super.eIsSet(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public String toString()
  {
    if (eIsProxy()) return super.toString();

    StringBuffer result = new StringBuffer(super.toString());
    result.append(" (sym: ");
    result.append(sym);
    result.append(')');
    return result.toString();
  }

} //RExpImpl
