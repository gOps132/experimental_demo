

export function EaseInOutQuad(t, b, c, d) {
	t /= d/2;
	if (t < 1) return c/2*t*t + b;
	t--;
	return -c/2 * (t*(t-2) - 1) + b;
}

export function EaseOutCirc(x) {
	return Math.sqrt(1 - Math.pow(x - 1, 2));
}

export function EaseInOutElastic(x) {
	const c5 = (2 * Math.PI) / 4.5;
	
	return x === 0
		? 0
		: x === 1
		? 1
		: x < 0.5
		? -(Math.pow(2, 20 * x - 10) * Math.sin((20 * x - 11.125) * c5)) / 2
		: (Math.pow(2, -20 * x + 10) * Math.sin((20 * x - 11.125) * c5)) / 2 + 1;
}