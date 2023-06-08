<script>
	export let chats = [];
	export let chat = null;
	export let current_user = null;
	export let text = null;
	export let messages = [];
	export let pushEvent;

	function join(chat_id) {
		console.log("join", chat_id);
		pushEvent("join", { chat_id: chat_id }, () => {});
	}
	function send() {
		pushEvent("send", { text: text }, () => {
			text = "";
		});
	}
</script>

<div>
	<ul class="flex flex-row">
		{#each chats as chat}
			<li class="mr-4">
				<button
					on:click|preventDefault={(e) => join(chat.id)}
					class="font-semibold text-brand hover:underline"
				>
					{chat.title}
				</button>
			</li>
		{/each}
		<button
			phx-click="new_chat"
			class="bg-blue-500 hover:bg-blue-700 text-white font-bold rounded"
		>
			New chat
		</button>
	</ul>
	<h1>You are <b>{current_user.email}</b> in the chat <b>{chat.title}</b></h1>
	<div
		class="messages"
		style="border: 1px solid #eee; height: 400px; overflow: scroll; margin-bottom: 8px;"
	>
		{#each messages as message}
			<p style="margin: 2px;">
				<b>{message.user.email}</b>: {message.body}
			</p>
		{/each}
	</div>

	<form on:submit|preventDefault={send}>
		<div class="flex flex-row">
			<input
				type="text"
				name="text"
				class="flex-grow border border-gray-300 rounded-md px-3 py-2 mr-4 focus:outline-none focus:border-blue-300"
				required
				bind:value={text}
			/>
			<button
				phx-disable-with="Sending..."
				class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
			>
				Send<!--  <.icon name="hero-paper-airplane-solid" class="ml-2" /> -->
			</button>
		</div>
	</form>
</div>
