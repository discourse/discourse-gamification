import Helper from "@ember/component/helper";

export function format(number) {
  return number.toLocaleString(undefined, {});
}

export default Helper.helper(format);
