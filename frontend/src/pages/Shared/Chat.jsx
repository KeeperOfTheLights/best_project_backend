import React, { useState, useEffect, useRef } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import "./ChatPage.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function ChatPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const { token, logout, role, user } = useAuth();
  const [chats, setChats] = useState([]);
  const [selectedSupplierId, setSelectedSupplierId] = useState(null);
  const [currentUserId, setCurrentUserId] = useState(null);
  const [currentConsumerId, setCurrentConsumerId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [messagesLoading, setMessagesLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState("");
  const messagesEndRef = useRef(null);
  const messagesContainerRef = useRef(null);
  const shouldAutoScrollRef = useRef(true);
  const lastMessageIdsRef = useRef(new Set());
  const hasNewMessagesRef = useRef(false);

  useEffect(() => {
    if (!token) {
      logout();
      navigate("/login");
      return;
    }

    const fetchChats = async () => {
      setLoading(true);
      setError("");

      try {
        let linkedPartners = [];

        if (role === "consumer") {
          const linksRes = await fetch(`${API_BASE}/consumer/links/`, {
            headers: { Authorization: `Bearer ${token}` },
          });

          if (linksRes.status === 401) {
            logout();
            navigate("/login");
            return;
          }

          if (linksRes.ok) {
            const links = await linksRes.json();
            const linkedSuppliers = links.filter((link) => link.status === "linked");
            
            if (links.length > 0 && links[0].consumer) {
              setCurrentConsumerId(links[0].consumer);
            }

            const suppliersRes = await fetch(`${API_BASE}/suppliers/`, {
              headers: { Authorization: `Bearer ${token}` },
            });

            if (suppliersRes.ok) {
              const allSuppliers = await suppliersRes.json();
              linkedPartners = linkedSuppliers.map((link) => {
                const supplier = allSuppliers.find((s) => s.id === link.supplier);
                return {
                  supplierId: link.supplier,
                  name: supplier?.full_name || `Supplier #${link.supplier}`,
                  type: "supplier",
                };
              });
            }
          }
        } else if (role === "supplier") {
          const linksRes = await fetch(`${API_BASE}/links/`, {
            headers: { Authorization: `Bearer ${token}` },
          });

          if (linksRes.status === 401) {
            logout();
            navigate("/login");
            return;
          }

          if (linksRes.ok) {
            const links = await linksRes.json();
            if (links.length > 0 && links[0].supplier) {
              setCurrentUserId(links[0].supplier);
            }
            linkedPartners = links
              .filter((link) => link.status === "linked")
              .map((link) => ({
                consumerId: link.consumer,
                name: link.consumer_name || `Consumer #${link.consumer}`,
                type: "consumer",
              }));
          }
        }

        setChats(linkedPartners);
        
        const consumerIdToSelect = location.state?.selectConsumerId;
        
        if (consumerIdToSelect && role === "supplier") {
          const consumerChat = linkedPartners.find(
            (chat) => Number(chat.consumerId) === Number(consumerIdToSelect)
          );
          if (consumerChat) {
            setSelectedSupplierId(consumerChat.consumerId);
          }
        } else if (linkedPartners.length > 0 && !selectedSupplierId) {
          if (role === "consumer" && linkedPartners[0].supplierId) {
            setSelectedSupplierId(linkedPartners[0].supplierId);
          }
        }
      } catch (err) {
        setError(err.message || "Failed to load chats");
      } finally {
        setLoading(false);
      }
    };

    fetchChats();
  }, [token, role, location.state]);

  useEffect(() => {
    if (!selectedSupplierId || !token) {
      setMessages([]);
      lastMessageIdsRef.current = new Set();
      return;
    }

    const checkIfAtBottom = () => {
      if (!messagesContainerRef.current) return true;
      const container = messagesContainerRef.current;
      const threshold = 100;
      return container.scrollHeight - container.scrollTop - container.clientHeight < threshold;
    };

    const fetchMessages = async (isInitialLoad = false) => {
      if (!isInitialLoad) {
        shouldAutoScrollRef.current = checkIfAtBottom();
      } else {
        shouldAutoScrollRef.current = true;
        lastMessageIdsRef.current = new Set();
      }
      
      setError("");

      try {
        const partnerId = selectedSupplierId;
        const res = await fetch(`${API_BASE}/chat/${partnerId}/`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (res.status === 401) {
          logout();
          navigate("/login");
          return;
        }

        if (!res.ok) {
          const text = await res.text();
          throw new Error(text || "Failed to load messages");
        }

        const data = await res.json();
        const formattedMessages = (Array.isArray(data) ? data : []).map((msg) => {
          let isOwn = false;
          if (role === "consumer" && currentConsumerId) {
            isOwn = Number(msg.sender) === Number(currentConsumerId);
          } else if (role === "supplier" && currentUserId) {
            isOwn = Number(msg.sender) === Number(currentUserId);
          }
          
          return {
            id: msg.id,
            text: msg.text,
            senderName: msg.sender_name,
            timestamp: msg.timestamp,
            senderId: msg.sender,
            isOwn: isOwn,
          };
        });

        if (!isInitialLoad) {
          const currentMessageIds = new Set(formattedMessages.map(m => m.id));
          const hadNewMessages = formattedMessages.some(msg => !lastMessageIdsRef.current.has(msg.id));
          hasNewMessagesRef.current = hadNewMessages;
          
          if (hadNewMessages) {
          } else {
            shouldAutoScrollRef.current = false;
          }
          
          lastMessageIdsRef.current = currentMessageIds;
        } else {
          lastMessageIdsRef.current = new Set(formattedMessages.map(m => m.id));
          shouldAutoScrollRef.current = true;
          hasNewMessagesRef.current = true;
        }

        setMessages(formattedMessages);
      } catch (err) {
        setError(err.message || "Failed to load messages");
      }
    };

    setMessagesLoading(true);
    fetchMessages(true).finally(() => setMessagesLoading(false));

    const interval = setInterval(() => fetchMessages(false), 3000);
    return () => clearInterval(interval);
  }, [selectedSupplierId, role, token, currentUserId, currentConsumerId]);

  useEffect(() => {
    const container = messagesContainerRef.current;
    if (!container) {
      const timeout = setTimeout(() => {
        const retryContainer = messagesContainerRef.current;
        if (retryContainer) {
          const handleScroll = () => {
            const threshold = 100;
            const isAtBottom = retryContainer.scrollHeight - retryContainer.scrollTop - retryContainer.clientHeight < threshold;
            shouldAutoScrollRef.current = isAtBottom;
          };
          retryContainer.addEventListener("scroll", handleScroll);
        }
      }, 100);
      return () => clearTimeout(timeout);
    }

    const handleScroll = () => {
      const threshold = 100;
      const isAtBottom = container.scrollHeight - container.scrollTop - container.clientHeight < threshold;
      shouldAutoScrollRef.current = isAtBottom;
    };

    container.addEventListener("scroll", handleScroll);
    return () => container.removeEventListener("scroll", handleScroll);
  }, [messages]);

  useEffect(() => {
    // Only auto-scroll if:
    // 1. User is at bottom (shouldAutoScrollRef.current is true)
    // 2. AND there are new messages OR it's an initial load
    // This prevents scrolling when messages are re-fetched but unchanged
    if (shouldAutoScrollRef.current && messagesEndRef.current && hasNewMessagesRef.current) {
      setTimeout(() => {
        if (messagesEndRef.current && shouldAutoScrollRef.current) {
          messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
        }
      }, 50);
    }
    hasNewMessagesRef.current = false;
  }, [messages]);

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!newMessage.trim() || !selectedSupplierId) return;

    setSending(true);
    setError("");

    try {
      let url, body;
      
      if (role === "consumer") {
        url = `${API_BASE}/chat/${selectedSupplierId}/send/`;
        body = { text: newMessage.trim() };
      } else {
        if (!currentUserId) {
          throw new Error("Unable to determine supplier ID. Please refresh the page.");
        }
        url = `${API_BASE}/chat/${currentUserId}/send/`;
        body = { text: newMessage.trim(), consumer_id: selectedSupplierId };
      }

      const res = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(body),
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const text = await res.text();
        throw new Error(text || "Failed to send message");
      }

      const sentMessage = await res.json();
      
      if (role === "consumer") {
        setMessages((prev) => [
          ...prev,
          {
            id: sentMessage.id,
            text: sentMessage.text,
            senderName: sentMessage.sender_name || "You",
            timestamp: sentMessage.timestamp,
            senderId: sentMessage.sender,
            isOwn: true,
          },
        ]);
      } else {
        setMessages((prev) => [
          ...prev,
          {
            id: sentMessage.id || Date.now(),
            text: sentMessage.text,
            senderName: sentMessage.sender_name || "You",
            timestamp: sentMessage.timestamp || new Date().toISOString(),
            senderId: currentUserId,
            isOwn: true,
          },
        ]);
      }

      setNewMessage("");
      // Auto-scroll after sending - force scroll to bottom
      shouldAutoScrollRef.current = true;
      hasNewMessagesRef.current = true;
      setTimeout(() => {
        if (messagesEndRef.current) {
          messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
        }
      }, 100);
    } catch (err) {
      setError(err.message || "Failed to send message");
    } finally {
      setSending(false);
    }
  };

  const formatTime = (timestamp) => {
    if (!timestamp) return "";
    try {
      const date = new Date(timestamp);
      const now = new Date();
      const diffMs = now - date;
      const diffMins = Math.floor(diffMs / 60000);

      if (diffMins < 1) return "Just now";
      if (diffMins < 60) return `${diffMins}m ago`;
      if (diffMins < 1440) return `${Math.floor(diffMins / 60)}h ago`;

      return date.toLocaleDateString();
    } catch {
      return timestamp;
    }
  };

  const filteredChats = chats.filter((chat) =>
    chat.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const selectedChat = chats.find(
    (chat) =>
      (role === "consumer" && chat.supplierId === selectedSupplierId) ||
      (role === "supplier" && chat.consumerId === selectedSupplierId)
  );

  const getAvatarUrl = (name) => {
    return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=61dafb&color=fff`;
  };

  return (
    <div className="chat-page-container">
      <div className="chat-sidebar">
        <div className="chat-sidebar-header">
          <h2>Messages</h2>
        </div>

        <div className="chat-sidebar-search">
          <input
            type="text"
            placeholder="Search conversations..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="chat-search-input"
          />
        </div>

        {loading ? (
          <div className="chat-loading">Loading chats...</div>
        ) : error ? (
          <div className="chat-error">{error}</div>
        ) : filteredChats.length === 0 ? (
          <div className="chat-empty">
            {role === "consumer"
              ? "No linked suppliers to chat with"
              : "No linked consumers to chat with"}
          </div>
        ) : (
          <div className="chat-list">
            {filteredChats.map((chat) => {
              const chatId =
                role === "consumer" ? chat.supplierId : chat.consumerId;
              return (
                <div
                  key={chatId}
                  className={`chat-item ${
                    selectedSupplierId === chatId ? "active" : ""
                  }`}
                  onClick={() => setSelectedSupplierId(chatId)}
                >
                  <div className="chat-item-avatar">
                    <img src={getAvatarUrl(chat.name)} alt={chat.name} />
                  </div>
                  <div className="chat-item-info">
                    <div className="chat-item-header">
                      <h4>{chat.name}</h4>
                    </div>
                    <div className="chat-item-footer">
                      <p className="chat-last-message">
                        {role === "consumer" ? "Supplier" : "Consumer"}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      <div className="chat-window">
        {selectedChat ? (
          <>
            <div className="chat-window-header">
              <div className="chat-partner-info">
                <img
                  src={getAvatarUrl(selectedChat.name)}
                  alt={selectedChat.name}
                  className="partner-avatar"
                />
                <div>
                  <h3>{selectedChat.name}</h3>
                  <span className="partner-status">
                    {role === "consumer" ? "Supplier" : "Consumer"}
                  </span>
                </div>
              </div>
            </div>

            <div className="chat-messages" ref={messagesContainerRef}>
              {messagesLoading && messages.length === 0 ? (
                <div className="messages-loading">Loading messages...</div>
              ) : messages.length === 0 ? (
                <div className="messages-empty">
                  No messages yet. Start the conversation!
                </div>
              ) : (
                messages.map((message) => (
                  <div
                    key={message.id}
                    className={`message ${
                      message.isOwn ? "message-own" : "message-other"
                    }`}
                  >
                    {!message.isOwn && (
                      <img
                        src={getAvatarUrl(selectedChat.name)}
                        alt=""
                        className="message-avatar"
                      />
                    )}
                    <div className="message-content">
                      <div className="message-bubble">
                        <p>{message.text}</p>
                      </div>
                      <span className="message-time">
                        {formatTime(message.timestamp)}
                      </span>
                    </div>
                  </div>
                ))
              )}
              <div ref={messagesEndRef} />
            </div>

            <form className="chat-input-container" onSubmit={handleSendMessage}>
              <input
                type="text"
                placeholder="Type a message..."
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                className="message-input"
                disabled={sending}
              />
              <button
                type="submit"
                className="send-btn"
                disabled={!newMessage.trim() || sending}
              >
                {sending ? "..." : "➤"}
              </button>
            </form>

            {error && <div className="chat-error-inline">{error}</div>}
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
