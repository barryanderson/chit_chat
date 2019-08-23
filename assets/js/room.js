let Room = {
  init(socket, el) {
    let roomId = el.getAttribute("data-id")
    console.log(`element: ${el}, roomId: ${roomId}`)
    socket.connect()
    this.onReady(roomId, socket)
  },
  onReady(roomId, socket) {
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let postButton = document.getElementById("msg-submit")
    let channel = socket.channel("rooms:" + roomId)

    postButton.addEventListener("click", (e) => {
      channel.push("new_chat", {body: msgInput.value})
      .receive("error", resp => { console.log(resp) })

      msgInput.value = ""
      e.preventDefault()
    })

    channel.on("new_chat", (resp) => {
      console.log(resp)
      this.renderChat(msgContainer, resp)
    })

    channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
  },
  esc(input) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(input))
    return div.innerHTML
  },
  renderChat(msgContainer, { body }) {
    let div = document.createElement("div")
    div.innerHTML = `
    <span>
      <strong>Anon</strong>: ${this.esc(body)}
    </span>
    `

    msgContainer.appendChild(div)
    msgContainer.scrollTop = msgContainer.scrollHeight
  }
}

export default Room
