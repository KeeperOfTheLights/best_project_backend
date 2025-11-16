import React, { useState } from "react";
import "./ChatPage.css";

const dummyChats = [
  {
    id: 1,
    partnerId: 101,
    partnerName: "Fresh Farm Products",
    partnerType: "Supplier",
    lastMessage: "Your order has been confirmed",
    lastMessageTime: "10:30 AM",
    unreadCount: 2,
    avatar: "https://ui-avatars.com/api/?name=Fresh+Farm&background=4caf50&color=fff",
    isOnline: true
  },
  {
    id: 2,
    partnerId: 102,
    partnerName: "Green Leaf Restaurant",
    partnerType: "Consumer",
    lastMessage: "Can we increase the order quantity?",
    lastMessageTime: "Yesterday",
    unreadCount: 0,
    avatar: "https://ui-avatars.com/api/?name=Green+Leaf&background=61dafb&color=fff",
    isOnline: false
  },
  {
    id: 3,
    partnerId: 103,
    partnerName: "Premium Meat Supply",
    partnerType: "Supplier",
    lastMessage: "Delivery scheduled for tomorrow",
    lastMessageTime: "2 days ago",
    unreadCount: 0,
    avatar: "https://ui-avatars.com/api/?name=Premium+Meat&background=f44336&color=fff",
    isOnline: true
  }
];

const dummyMessages = {
  1: [
    {
      id: 1,
      senderId: 101,
      senderName: "Fresh Farm Products",
      text: "Hello! Thank you for your order.",
      timestamp: "10:15 AM",
      isOwn: false
    },
    {
      id: 2,
      senderId: "me",
      senderName: "You",
      text: "Hi! When can I expect delivery?",
      timestamp: "10:20 AM",
      isOwn: true
    },
    {
      id: 3,
      senderId: 101,
      senderName: "Fresh Farm Products",
      text: "Your order has been confirmed and will be delivered tomorrow.",
      timestamp: "10:30 AM",
      isOwn: false
    }
  ],
  2: [
    {
      id: 1,
      senderId: 102,
      senderName: "Green Leaf Restaurant",
      text: "Can we increase the order quantity?",
      timestamp: "Yesterday 3:45 PM",
      isOwn: false
    },
    {
      id: 2,
      senderId: "me",
      senderName: "You",
      text: "Yes, sure! How much do you need?",
      timestamp: "Yesterday 4:00 PM",
      isOwn: true
    }
  ],
  3: [
    {
      id: 1,
      senderId: 103,
      senderName: "Premium Meat Supply",
      text: "Delivery scheduled for tomorrow",
      timestamp: "2 days ago",
      isOwn: false
    }
  ]
};

export default function ChatPage({ userRole }) {
  const [chats] = useState(dummyChats);
  const [selectedChatId, setSelectedChatId] = useState(1);
  const [messages, setMessages] = useState(dummyMessages);
  const [newMessage, setNewMessage] = useState("");
  const [searchQuery, setSearchQuery] = useState("");

  const selectedChat = chats.find(chat => chat.id === selectedChatId);
  const currentMessages = messages[selectedChatId] || [];

  const handleSendMessage = (e) => {
    e.preventDefault();
    if (!newMessage.trim()) return;

    const newMsg = {
      id: Date.now(),
      senderId: "me",
      senderName: "You",
      text: newMessage,
      timestamp: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
      isOwn: true
    };

    setMessages({
      ...messages,
      [selectedChatId]: [...(messages[selectedChatId] || []), newMsg]
    });

    setNewMessage("");
  };

  const handleFileUpload = (e) => {
    const file = e.target.files[0];
    if (file) {
      alert(`File selected: ${file.name}\n(File upload will be implemented with backend)`);
    }
  };

  const filteredChats = chats.filter(chat =>
    chat.partnerName.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="chat-page-container">
      {/* Sidebar with chat list */}
      <div className="chat-sidebar">
        <div className="chat-sidebar-header">
          <h2>Messages</h2>
          <button className="new-chat-btn" title="New Chat">
            ✉️
          </button>
        </div>

        <div className="chat-search">
          <input
            type="text"
            placeholder="Search conversations..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="chat-search-input"
          />
        </div>

        <div className="chat-list">
          {filteredChats.map(chat => (
            <div
              key={chat.id}
              className={`chat-item ${selectedChatId === chat.id ? "active" : ""}`}
              onClick={() => setSelectedChatId(chat.id)}
            >
              <div className="chat-item-avatar">
                <img src={chat.avatar} alt={chat.partnerName} />
                {chat.isOnline && <span className="online-indicator"></span>}
              </div>
              <div className="chat-item-info">
                <div className="chat-item-header">
                  <h4>{chat.partnerName}</h4>
                  <span className="chat-time">{chat.lastMessageTime}</span>
                </div>
                <div className="chat-item-footer">
                  <p className="chat-last-message">{chat.lastMessage}</p>
                  {chat.unreadCount > 0 && (
                    <span className="unread-badge">{chat.unreadCount}</span>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Chat window */}
      <div className="chat-window">
        {selectedChat ? (
          <>
            {/* Chat header */}
            <div className="chat-window-header">
              <div className="chat-partner-info">
                <img src={selectedChat.avatar} alt={selectedChat.partnerName} className="partner-avatar" />
                <div>
                  <h3>{selectedChat.partnerName}</h3>
                  <span className="partner-status">
                    {selectedChat.isOnline ? "🟢 Online" : "⚫ Offline"}
                  </span>
                </div>
              </div>
              <div className="chat-actions">
                <button className="icon-btn" title="Call">📞</button>
                <button className="icon-btn" title="Video">📹</button>
                <button className="icon-btn" title="More">⋮</button>
              </div>
            </div>

            {/* Messages area */}
            <div className="chat-messages">
              {currentMessages.map(message => (
                <div
                  key={message.id}
                  className={`message ${message.isOwn ? "message-own" : "message-other"}`}
                >
                  {!message.isOwn && (
                    <img src={selectedChat.avatar} alt="" className="message-avatar" />
                  )}
                  <div className="message-content">
                    <div className="message-bubble">
                      <p>{message.text}</p>
                    </div>
                    <span className="message-time">{message.timestamp}</span>
                  </div>
                </div>
              ))}
            </div>

            {/* Message input */}
            <form className="chat-input-container" onSubmit={handleSendMessage}>
              <button type="button" className="attach-btn" title="Attach file">
                <input
                  type="file"
                  id="file-upload"
                  style={{ display: "none" }}
                  onChange={handleFileUpload}
                  accept="image/*,.pdf,.doc,.docx"
                />
                <label htmlFor="file-upload" style={{ cursor: "pointer" }}>
                  📎
                </label>
              </button>

              <input
                type="text"
                placeholder="Type a message..."
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                className="message-input"
              />

              <button type="button" className="emoji-btn" title="Emoji">
                😊
              </button>

              <button type="submit" className="send-btn" disabled={!newMessage.trim()}>
                ➤
              </button>
            </form>
          </>
        ) : (
          <div className="no-chat-selected">
            <h3>Select a conversation</h3>
            <p>Choose a conversation from the list to start messaging</p>
          </div>
        )}
      </div>
    </div>
  );
}