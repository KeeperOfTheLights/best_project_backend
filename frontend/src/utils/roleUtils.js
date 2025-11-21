export const SUPPLIER_ROLES = ["owner", "manager", "sales"];

export const is_supplier_side = (role) => {
  return SUPPLIER_ROLES.includes(role);
};

export const is_catalog_manager = (role) => {
  return role === "owner" || role === "manager";
};

export const is_owner = (role) => {
  return role === "owner";
};

export const is_manager = (role) => {
  return role === "manager";
};

export const is_sales = (role) => {
  return role === "sales";
};

