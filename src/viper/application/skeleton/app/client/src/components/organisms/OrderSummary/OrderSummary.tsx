import React, { FunctionComponent, HTMLAttributes, useEffect, useMemo } from 'react';
import cx from 'classnames';
import { useReactiveVar } from '@apollo/client';
import { CartItem, CartTableTotal, ProductPrice } from '@inviqa/viper-ui';
import { useTranslation } from 'react-i18next';
import { checkoutIdVar } from '~hooks/cart';
import { useGetCheckoutLazyQuery } from '~hooks/apollo';
import CartItemCard from '../Cart/CartItemCard';
import Result from '../../utility/Result/Result';

const OrderSummary: FunctionComponent<HTMLAttributes<HTMLDivElement>> = ({ className, ...props }) => {
  const { t } = useTranslation('commerce');
  const checkoutId = useReactiveVar(checkoutIdVar);
  const [getCheckout, { data, loading, error, called }] = useGetCheckoutLazyQuery();
  const cart = data?.checkout?.cart;

  useEffect(() => {
    if (checkoutId) {
      getCheckout({ variables: { checkoutId } });
    }
  }, [getCheckout, checkoutId]);

  const items: CartItem[] = useMemo(
    () =>
      (cart?.items ?? []).map(item => ({
        id: item.id,
        name: item.product.name,
        totalPrice: item.rowTotal,
        quantity: item.quantity,
        url: item.product.url,
        image: item.product.thumbnailImage?.url
          ? {
              url: item.product.thumbnailImage?.url,
              alt: item.product.thumbnailImage?.alt ?? ''
            }
          : undefined,
        productOptions: item.productOptions || null
      })),
    [cart?.items]
  );

  const totals: CartTableTotal[] = useMemo(() => {
    if (!cart?.totals) return [];

    const { grandTotal, subtotalIncludingTax, discounts } = cart.totals;
    const shippingMethod = data?.checkout?.shippingMethod;

    return [
      { label: t('Cart.Total.Subtotal'), price: subtotalIncludingTax },
      ...discounts.map(({ label, amount }) => ({ label, price: amount })),
      ...(shippingMethod
        ? [
            {
              label: t('Cart.Total.Shipping', { method: shippingMethod.label }),
              price: shippingMethod.priceIncludingTax
            }
          ]
        : []),
      { label: t('Cart.Total.GrandTotal'), price: grandTotal }
    ];
  }, [cart?.totals, data?.checkout?.shippingMethod, t]);

  return (
    <div className={cx('order-summary', className)} {...props}>
      <Result loading={loading || !called} error={error?.message}>
        <h2>{t('Checkout.OrderSummary')}</h2>
        {/* voiceover will remove these semantics if list does not have list styling so role is necessary */}
        {/* eslint-disable-next-line jsx-a11y/no-redundant-roles */}
        <ul role="list" className="order-summary__list">
          {items.map(item => (
            <li key={item.id} className="mb-3 last:mb-0">
              <CartItemCard readonly {...item} />
            </li>
          ))}
        </ul>

        <table>
          <tbody>
            {totals.map(({ label, price }) => (
              <tr key={label}>
                <th>{label}</th>
                <td>
                  <ProductPrice price={price} className="text-xs" />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Result>
    </div>
  );
};

export default OrderSummary;
