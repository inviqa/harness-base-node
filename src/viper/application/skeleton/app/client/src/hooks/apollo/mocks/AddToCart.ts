import { MutationResult } from '@apollo/client';
import { AddToCartMutationVariables, AddToCartDocument, AddToCartMutation } from '../generated';
import { defaultCartTotals, defaultCouponCodes } from './GetCart';

export const addToCartMock = (
  {
    cartId = 'mock-cart-id',
    items = [{ id: 'mock-id', variantId: null, quantity: 1 }]
  }: Partial<AddToCartMutationVariables> = {},
  {
    data = {
      addToCart: {
        __typename: 'Cart',
        id: '',
        numberOfItems: 0,
        items: [],
        totals: defaultCartTotals,
        couponCodes: defaultCouponCodes
      }
    },
    loading = false,
    error = undefined
  }: Partial<MutationResult<AddToCartMutation>> = {}
) => ({
  request: {
    query: AddToCartDocument,
    variables: {
      cartId,
      items
    }
  },
  result: {
    data,
    loading,
    error
  }
});
