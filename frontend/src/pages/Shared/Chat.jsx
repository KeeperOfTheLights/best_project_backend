import React, { useState, useEffect, useRef } from "react";
import { useTranslation } from "react-i18next";
import { useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "../../context/Auth-Context";
import { is_supplier_side } from "../../utils/roleUtils";
import "./ChatPage.css";

const API_BASE = "http://127.0.0.1:8000/api/accounts";

export default function ChatPage() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const { token, logout, role, userId, loading: authLoading } = useAuth();
  const [chats, setChats] = useState([]);
  const [selectedSupplierId, setSelectedSupplierId] = useState(null);
  const [companyOwnerId, setCompanyOwnerId] = useState(null);
  const [currentConsumerId, setCurrentConsumerId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [messagesLoading, setMessagesLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState("");
  const [selectedFile, setSelectedFile] = useState(null);
  const [cannedReplies, setCannedReplies] = useState([]);
  const [showCannedReplies, setShowCannedReplies] = useState(false);
  const [orders, setOrders] = useState([]);
  const [products, setProducts] = useState([]);
  const [showOrderSelector, setShowOrderSelector] = useState(false);
  const [showProductSelector, setShowProductSelector] = useState(false);
  const messagesEndRef = useRef(null);
  const messagesContainerRef = useRef(null);
  const shouldAutoScrollRef = useRef(true);
  const lastMessageIdsRef = useRef(new Set());
  const hasNewMessagesRef = useRef(false);

  useEffect(() => {
    if (authLoading) return;
    
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
        } else if (is_supplier_side(role)) {
          if (role === "owner") {
            setCompanyOwnerId(userId);
          }
          
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
              setCompanyOwnerId(links[0].supplier);
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
        
        if (consumerIdToSelect && is_supplier_side(role)) {
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
        setError(err.message || t("chat.failedToLoadChats"));
      } finally {
        setLoading(false);
      }
    };

    fetchChats();
  }, [token, role, location.state, authLoading]);

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
          throw new Error(text || t("chat.failedToLoadMessages"));
        }

        const data = await res.json();
        const formattedMessages = (Array.isArray(data) ? data : []).map((msg) => {
          let isOwn = false;
          if (role === "consumer" && userId) {
            isOwn = Number(msg.sender) === Number(userId);
          } else if (is_supplier_side(role) && userId) {
            isOwn = Number(msg.sender) === Number(userId);
          }
          
          return {
            id: msg.id,
            text: msg.text || "",
            senderName: msg.sender_name,
            timestamp: msg.timestamp,
            senderId: msg.sender,
            isOwn: isOwn,
            messageType: msg.message_type || "text",
            attachmentUrl: msg.attachment_url,
            attachmentName: msg.attachment_name,
            orderId: msg.order_id,
            productId: msg.product_id,
            productName: msg.product_name,
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
        setError(err.message || t("chat.failedToLoadMessages"));
      }
    };

    setMessagesLoading(true);
    fetchMessages(true).finally(() => setMessagesLoading(false));

    const interval = setInterval(() => fetchMessages(false), 3000);
    return () => clearInterval(interval);
  }, [selectedSupplierId, role, token, userId, currentConsumerId, authLoading]);

  useEffect(() => {
    if (authLoading || !is_supplier_side(role) || !token) return;
    
    const fetchCannedReplies = async () => {
      try {
        const res = await fetch(`${API_BASE}/canned-replies/`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (res.ok) {
          const data = await res.json();
          setCannedReplies(Array.isArray(data) ? data : []);
        }
      } catch (err) {
        console.error("Failed to load canned replies:", err);
      }
    };

    fetchCannedReplies();
  }, [role, token, authLoading]);

  useEffect(() => {
    if (authLoading || !selectedSupplierId || !token) return;
    
    if (role === "consumer") {
      const fetchOrders = async () => {
        try {
          const res = await fetch(`${API_BASE}/orders/my/`, {
            headers: { Authorization: `Bearer ${token}` },
          });
          if (res.ok) {
            const data = await res.json();
            const supplierOrders = Array.isArray(data) 
              ? data.filter(o => Number(o.supplier) === Number(selectedSupplierId))
              : [];
            setOrders(supplierOrders);
          }
        } catch (err) {
          console.error("Failed to load orders:", err);
        }
      };
      fetchOrders();
    } else if (is_supplier_side(role)) {
      const fetchProducts = async () => {
        try {
          const res = await fetch(`${API_BASE}/products/`, {
            headers: { Authorization: `Bearer ${token}` },
          });
          if (res.ok) {
            const data = await res.json();
            setProducts(Array.isArray(data) ? data : []);
          }
        } catch (err) {
          console.error("Failed to load products:", err);
        }
      };
      fetchProducts();
    }
  }, [selectedSupplierId, role, token, authLoading]);

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
    if (shouldAutoScrollRef.current && messagesContainerRef.current && hasNewMessagesRef.current) {
      setTimeout(() => {
        if (messagesContainerRef.current && shouldAutoScrollRef.current) {
          messagesContainerRef.current.scrollTop = messagesContainerRef.current.scrollHeight;
        }
      }, 50);
    }
    hasNewMessagesRef.current = false;
  }, [messages]);

  const handleSendMessage = async (e) => {
    e.preventDefault();
    if ((!newMessage.trim() && !selectedFile) || !selectedSupplierId) return;

    setSending(true);
    setError("");

    try {
      let url;
      const formData = new FormData();
      
      if (role === "consumer") {
        url = `${API_BASE}/chat/${selectedSupplierId}/send/`;
      } else {
        if (!selectedSupplierId) {
          throw new Error(t("chat.selectConsumer"));
        }
        if (!companyOwnerId) {
          throw new Error(t("chat.unableToDetermineSupplier"));
        }
        url = `${API_BASE}/chat/${companyOwnerId}/send/`;
        formData.append("consumer_id", selectedSupplierId);
      }

      if (newMessage.trim()) {
        formData.append("text", newMessage.trim());
      }
      
      if (selectedFile) {
        formData.append("attachment", selectedFile);
      }

      const res = await fetch(url, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: formData,
      });

      if (res.status === 401) {
        logout();
        navigate("/login");
        return;
      }

      if (!res.ok) {
        const text = await res.text();
        throw new Error(text || t("chat.failedToSendMessage"));
      }

      const sentMessage = await res.json();
      
      setMessages((prev) => [
        ...prev,
        {
          id: sentMessage.id,
          text: sentMessage.text || "",
          senderName: sentMessage.sender_name || "You",
          timestamp: sentMessage.timestamp,
          senderId: sentMessage.sender,
          isOwn: true,
          messageType: sentMessage.message_type || "text",
          attachmentUrl: sentMessage.attachment_url,
          attachmentName: sentMessage.attachment_name,
          orderId: sentMessage.order_id,
          productId: sentMessage.product_id,
          productName: sentMessage.product_name,
        },
      ]);

      setNewMessage("");
      setSelectedFile(null);
      shouldAutoScrollRef.current = true;
      hasNewMessagesRef.current = true;
      setTimeout(() => {
        if (messagesContainerRef.current) {
          messagesContainerRef.current.scrollTop = messagesContainerRef.current.scrollHeight;
        }
      }, 100);
    } catch (err) {
      setError(err.message || t("chat.failedToSendMessage"));
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

      if (diffMins < 1) return t("chat.justNow");
      if (diffMins < 60) return t("chat.minutesAgo", { count: diffMins });
      if (diffMins < 1440) return t("chat.hoursAgo", { count: Math.floor(diffMins / 60) });

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
      (is_supplier_side(role) && chat.consumerId === selectedSupplierId)
  );

  const getAvatarUrl = (name) => {
    return `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=61dafb&color=fff`; // Used this site to show first letters of the users. Looks good ig
  };

  return (
    <div className="chat-page-container">
      <div className="chat-sidebar">
        <div className="chat-sidebar-header">
          <h2>{t("chat.messages")}</h2>
        </div>

        <div className="chat-sidebar-search">
          <input
            type="text"
            placeholder={t("chat.searchConversations")}
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="chat-search-input"
          />
        </div>

        {loading ? (
          <div className="chat-loading">{t("chat.loadingChats")}</div>
        ) : error ? (
          <div className="chat-error">{error}</div>
        ) : filteredChats.length === 0 ? (
          <div className="chat-empty">
            {role === "consumer"
              ? t("chat.noLinkedSuppliers")
              : t("chat.noLinkedConsumers")}
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
                        {role === "consumer" ? t("orders.supplier") : t("orders.consumer")}
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
                    {role === "consumer" ? t("orders.supplier") : t("orders.consumer")}
                  </span>
                </div>
              </div>
            </div>

            <div className="chat-messages" ref={messagesContainerRef}>
              {messagesLoading && messages.length === 0 ? (
                <div className="messages-loading">{t("chat.loadingMessages")}</div>
              ) : messages.length === 0 ? (
                <div className="messages-empty">
                  {t("chat.noMessages")} {t("chat.startConversation")}
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
                        {message.messageType === "receipt" && message.orderId && (
                          <div className="message-receipt">
                            <strong>{t("chat.orderReceipt")}</strong>
                            <p>{t("orders.orderNumber", { id: message.orderId })}</p>
                            <button 
                              onClick={() => {
                                const ordersPath = role === "consumer" ? "/ConsumerOrders" : "/SupplierOrders";
                                navigate(ordersPath, { state: { orderId: message.orderId } });
                              }}
                              className="view-order-btn"
                            >
                              {t("orders.viewDetails")}
                            </button>
                          </div>
                        )}
                        {message.messageType === "product_link" && message.productId && (
                          <div className="message-product-link">
                            <strong>{t("chat.productLink")}</strong>
                            <p>{message.productName || t("chat.productNumber", { id: message.productId })}</p>
                          </div>
                        )}
                        {message.attachmentUrl && (
                          <div className="message-attachment">
                            <a 
                              href={message.attachmentUrl} 
                              target="_blank" 
                              rel="noopener noreferrer"
                              className="attachment-link"
                            >
                              {message.attachmentName || t("chat.attachment")}
                            </a>
                          </div>
                        )}
                        {message.text && <p>{message.text}</p>}
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
                type="file"
                id="file-input"
                style={{ display: "none" }}
                onChange={(e) => setSelectedFile(e.target.files[0])}
                accept="image/*,application/pdf,.doc,.docx"
              />
              {selectedFile && (
                <span className="selected-file">
                  {selectedFile.name}
                  <button
                    type="button"
                    onClick={() => setSelectedFile(null)}
                    className="remove-file-btn"
                  >
                    x
                  </button>
                </span>
              )}
              <input
                type="text"
                placeholder={t("chat.typeMessage")}
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                className="message-input"
                disabled={sending}
              />
              <div className="chat-action-buttons">
                <label htmlFor="file-input" className="file-input-label" title="Attach File">
                  doc
                </label>
                {is_supplier_side(role) && (
                  <>
                    <button
                      type="button"
                      onClick={() => setShowCannedReplies(!showCannedReplies)}
                      className="action-btn"
                      title="Canned Replies"
                    >
                      👋
                    </button>
                    <button
                      type="button"
                      onClick={() => setShowProductSelector(!showProductSelector)}
                      className="action-btn"
                      title="Share Product"
                    >
                      🛒
                    </button>
                  </>
                )}
                {role === "consumer" && (
                  <button
                    type="button"
                    onClick={() => setShowOrderSelector(!showOrderSelector)}
                    className="action-btn action-btn-receipt"
                    title="Share Order Receipt"
                  >
                    Send Receipt
                  </button>
                )}
              </div>
              <button
                type="submit"
                className="send-btn"
                disabled={(!newMessage.trim() && !selectedFile) || sending}
              >
                {sending ? "..." : t("chat.sendMessage")}
              </button>
              {showCannedReplies && is_supplier_side(role) && (
                <div className="canned-replies-dropdown">
                  {cannedReplies.length === 0 ? (
                    <p>{t("chat.noCannedReplies")}</p>
                  ) : (
                    cannedReplies.map((reply) => (
                      <div
                        key={reply.id}
                        className="canned-reply-item"
                        onClick={() => {
                          setNewMessage(reply.message);
                          setShowCannedReplies(false);
                        }}
                      >
                        <strong>{reply.title}</strong>
                        <p>{reply.message.substring(0, 50)}...</p>
                      </div>
                    ))
                  )}
                </div>
              )}
              {showOrderSelector && role === "consumer" && (
                <div className="order-selector-dropdown">
                  {orders.length === 0 ? (
                    <p>{t("chat.noOrdersToShare")}</p>
                  ) : (
                    orders.map((order) => (
                      <div
                        key={order.id}
                        className="order-selector-item"
                        onClick={async () => {
                          try {
                            const url = `${API_BASE}/chat/${selectedSupplierId}/send/`;
                            const formData = new FormData();
                            formData.append("text", t("chat.orderReceiptText", { id: order.id }));
                            formData.append("message_type", "receipt");
                            formData.append("order_id", order.id);
                            
                            const res = await fetch(url, {
                              method: "POST",
                              headers: { Authorization: `Bearer ${token}` },
                              body: formData,
                            });
                            
                            if (res.ok) {
                              const sentMessage = await res.json();
                              setMessages((prev) => [...prev, {
                                id: sentMessage.id,
                                text: sentMessage.text || "",
                                senderName: sentMessage.sender_name || "You",
                                timestamp: sentMessage.timestamp,
                                senderId: sentMessage.sender,
                                isOwn: true,
                                messageType: "receipt",
                                orderId: sentMessage.order_id,
                              }]);
                              setShowOrderSelector(false);
                            }
                          } catch (err) {
                            setError(err.message);
                          }
                        }}
                      >
                        {t("orders.orderNumber", { id: order.id })} - {Number(order.total_price || 0).toLocaleString()} ₸
                      </div>
                    ))
                  )}
                </div>
              )}
              {showProductSelector && is_supplier_side(role) && (
                <div className="product-selector-dropdown">
                  {products.length === 0 ? (
                    <p>{t("chat.noProductsToShare")}</p>
                  ) : (
                    products.map((product) => (
                      <div
                        key={product.id}
                        className="product-selector-item"
                        onClick={async () => {
                          try {
                            const url = `${API_BASE}/chat/${companyOwnerId}/send/`;
                            const formData = new FormData();
                            formData.append("text", t("chat.checkOutProduct", { name: product.name }));
                            formData.append("message_type", "product_link");
                            formData.append("product_id", product.id);
                            formData.append("consumer_id", selectedSupplierId);
                            
                            const res = await fetch(url, {
                              method: "POST",
                              headers: { Authorization: `Bearer ${token}` },
                              body: formData,
                            });
                            
                            if (res.ok) {
                              const sentMessage = await res.json();
                              setMessages((prev) => [...prev, {
                                id: sentMessage.id,
                                text: sentMessage.text || "",
                                senderName: sentMessage.sender_name || "You",
                                timestamp: sentMessage.timestamp,
                                senderId: sentMessage.sender,
                                isOwn: true,
                                messageType: "product_link",
                                productId: sentMessage.product_id,
                                productName: sentMessage.product_name,
                              }]);
                              setShowProductSelector(false);
                            }
                          } catch (err) {
                            setError(err.message);
                          }
                        }}
                      >
                        {product.name} - {Number(product.price || 0).toLocaleString()} ₸
                      </div>
                    ))
                  )}
                </div>
              )}
            </form>

            {error && <div className="chat-error-inline">{error}</div>}
          </>
        ) : (
          <div className="no-chat-selected">
            <h3>{t("chat.selectChat")}</h3>
            <p>{role === "consumer" ? t("chat.selectSupplier") : t("chat.selectConsumer")}</p>
          </div>
        )}
      </div>
    </div>
  );
}
