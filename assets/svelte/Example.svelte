<script>
	export let number = 1;
	export let pushEvent;

	function increase() {
		pushEvent("set_number", { number: number + 1 }, () => {});
	}
	function decrease() {
		pushEvent("set_number", { number: number - 1 }, () => {});
	}
</script>

<body>
	<h1 class="text-center">Example svelte</h1>
	<p class="text-center">
		Number: <b class="text-7xl">{number}</b>
	</p>
	<div class="flex flex-row justify-center mt-4">
		<button
			class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mr-4"
			on:click={increase}
			>Increase
		</button>
		<button
			class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded ml-4"
			on:click={decrease}>Decrease</button
		>
	</div>
</body>
