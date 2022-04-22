import Helper from "@ember/component/helper";

export function kformatter(num) {
  return Math.abs(num) > 9999
    ? (Math.abs(num) / 1000).toFixed(1).toLocaleString(undefined) + "k"
    : Math.abs(num);
}

export default Helper.helper(kformatter);
