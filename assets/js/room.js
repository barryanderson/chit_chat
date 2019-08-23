import { Presence } from "phoenix"

let Room = {
  init(socket, el) {
    if(!el) return
    let roomId = el.getAttribute("data-id")
    console.log(`element: ${el}, roomId: ${roomId}`)
    socket.connect()
    this.onReady(roomId, socket)
  },
  onReady(roomId, socket) {
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let postButton = document.getElementById("msg-submit")
    let userContainer = document.getElementById("user-container")

    let channel = socket.channel("rooms:" + roomId)
    let presence = new Presence(channel)

    presence.onJoin(this.onJoin)
    presence.onLeave(this.onLeave)
    presence.onSync(() => { this.renderUsers(userContainer, presence) })

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
  renderChat(msgContainer, { username, body }) {
    let div = document.createElement("div")
    div.innerHTML = `
    <span>
      <strong>${this.esc(username)}</strong>: ${this.esc(body)}
    </span>
    `

    msgContainer.appendChild(div)
    msgContainer.scrollTop = msgContainer.scrollHeight
  },
  renderUsers(userContainer, { state }) {
    let guests = state[""] && state[""].metas
    let num_guests = guests ? guests.length : 0
    let users = Object
      .values(state)
      .map((x) => x.user.username)
      .filter((x) => x != "guest")

    let guestEl = document.createElement("div")
    guestEl.innerHTML = `Guests: ${num_guests}`

    let ul = document.createElement("ul")
    let userEls = users.map(user => {
      return `<li>${this.esc(user)}</li>`
    }).join('\n')

    ul.innerHTML = userEls
    userContainer.innerHTML = ul.outerHTML
    userContainer.appendChild(guestEl)
  },
  onJoin(id, current, newPres) {
    if(!current) {
      console.log(`${id ? "user:" + id : "anonymous"} has entered for the first time`, newPres)
    } else {
      console.log(`${id ? "user:" + id : "anonymous"} additional presence`, newPres)
    }
  },
  onLeave(id, current, leftPres) {
    if(current.metas.length === 0) {
      console.log(`${id ? "user:" + id : "anonymous"} has left from all devices`, leftPres)
    } else {
      console.log(`${id ? "user:" + id : "anonymous"} has left from a device`, leftPres)
    }
  }
}

export default Room
