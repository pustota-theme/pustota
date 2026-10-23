// Adds a hex alpha channel to a `#rrggbb` color.
module.exports = function alpha(color, value) {
  if (!/^#[0-9a-f]{6}$/.test(color)) {
    throw new Error(`Expected an opaque #rrggbb color, got: ${color}`);
  }
  return `${color}${value}`;
};
