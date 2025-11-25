import { describe, it, expect } from 'vitest';
import { is_supplier_side, is_catalog_manager, is_owner, is_sales } from '../roleUtils';

describe('roleUtils', () => {
  describe('is_supplier_side', () => {
    it('returns true for supplier roles', () => {
      expect(is_supplier_side('owner')).toBe(true);
      expect(is_supplier_side('manager')).toBe(true);
      expect(is_supplier_side('sales')).toBe(true);
    });

    it('returns false for consumer role', () => {
      expect(is_supplier_side('consumer')).toBe(false);
    });

    it('returns false for invalid role', () => {
      expect(is_supplier_side('invalid')).toBe(false);
      expect(is_supplier_side(null)).toBe(false);
      expect(is_supplier_side(undefined)).toBe(false);
    });
  });

  describe('is_catalog_manager', () => {
    it('returns true for owner and manager', () => {
      expect(is_catalog_manager('owner')).toBe(true);
      expect(is_catalog_manager('manager')).toBe(true);
    });

    it('returns false for other roles', () => {
      expect(is_catalog_manager('sales')).toBe(false);
      expect(is_catalog_manager('consumer')).toBe(false);
    });
  });

  describe('is_owner', () => {
    it('returns true only for owner', () => {
      expect(is_owner('owner')).toBe(true);
      expect(is_owner('manager')).toBe(false);
      expect(is_owner('sales')).toBe(false);
      expect(is_owner('consumer')).toBe(false);
    });
  });

  describe('is_sales', () => {
    it('returns true only for sales', () => {
      expect(is_sales('sales')).toBe(true);
      expect(is_sales('owner')).toBe(false);
      expect(is_sales('manager')).toBe(false);
      expect(is_sales('consumer')).toBe(false);
    });
  });
});

