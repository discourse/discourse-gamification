import Helper from "@ember/component/helper";

export function format(number) {
  return I18n.toNumber(number, { precision: 0 });
}

export default Helper.helper(format);
