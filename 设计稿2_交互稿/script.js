document.addEventListener('DOMContentLoaded', function () {

    // --- DOM Element References ---
    const body = document.body;
    const chatInput = document.getElementById('chat-input');
    const sendButton = document.getElementById('send-button');
    const viewTimelineBtn = document.getElementById('view-timeline-btn');
    const chatLog = document.querySelector('.chat-log');
    const timelineContent = document.getElementById('timeline-content');

    // --- Initial State & Data ---
    let isChatActive = false;
    const initialTimelineData = [
        { type: 'separator', date: '1月17日, 星期六' },
        { type: 'event', time: '10:00', title: '出发，前往森林公园', details: '从家里出发，预计车程1.5小时' },
        { type: 'event', time: '12:30', title: '公园野餐', details: '地点：中央草坪。我带三明治和水果！' },
        { type: 'separator', date: '1月18日, 星期日' },
        { type: 'event', time: '全天', title: '自由活动', details: '可以在附近逛逛，或者在酒店休息' },
    ];


    // --- Functions ---

    /**
     * Toggles the view between Chat and Timeline
     * @param {boolean} showChat - True to show chat, false to show timeline
     */
    function toggleView(showChat) {
        isChatActive = showChat;
        if (isChatActive) {
            body.classList.add('chat-active');
            chatInput.focus();
        } else {
            body.classList.remove('chat-active');
        }
    }
    
    /**
     * Renders the entire timeline from data
     * @param {Array} data - The timeline data array
     */
    function renderTimeline(data) {
        // Add the timeline axis first
        const axis = document.createElement('div');
        axis.className = 'timeline-axis';
        timelineContent.appendChild(axis);

        data.forEach(item => {
            const node = createTimelineNode(item);
            if (node) {
                timelineContent.appendChild(node);
            }
        });
    }

    /**
     * Creates a single timeline node element (event or separator)
     * @param {Object} item - A single item from timeline data
     * @returns {HTMLElement} - The generated DOM element
     */
    function createTimelineNode(item) {
        const node = document.createElement('div');
        node.className = 'timeline-node';

        if (item.type === 'separator') {
            node.classList.add('date-separator');
            node.innerHTML = `<span class="date-label">${item.date}</span>`;
        } else if (item.type === 'event') {
            node.innerHTML = `
                <div class="pulse-card">
                    <div class="card-details">
                        <p class="card-time">${item.time}</p>
                        <h2 class="card-title">${item.title}</h2>
                        <p class="card-details">${item.details}</p>
                    </div>
                </div>
            `;
        }
        return node;
    }

    /**
     * Simulates the chat interaction
     */
    function handleSendMessage() {
        const messageText = chatInput.value.trim();
        if (messageText === '') return;

        // 1. Add user message to chat log
        addMessageToLog('user', messageText);
        chatInput.value = '';

        // 2. Show AI "thinking" indicator
        const thinkingIndicator = addMessageToLog('ai', null, true);
        
        // 3. Simulate AI response after a delay
        setTimeout(() => {
            // Remove thinking indicator
            thinkingIndicator.remove();
            
            // Add AI response
            const aiResponse = `好的，已为你安排新的活动：“${messageText}”。`;
            addMessageToLog('ai', aiResponse);

            // 4. Dynamically add the new event to the timeline
            const newEvent = { type: 'event', time: '15:00', title: messageText, details: '由AI助手刚刚添加' };
            const newNode = createTimelineNode(newEvent);
            newNode.classList.add('new-event-appear'); // For animation
            timelineContent.appendChild(newNode);
            
            // 5. Briefly flash to timeline view to show the update
             setTimeout(() => {
                toggleView(false); // Switch to timeline
                setTimeout(() => {
                    // Optionally switch back to chat
                    // toggleView(true); 
                }, 1500);
            }, 500);

        }, 1500); // 1.5 second delay for simulation
    }

    /**
     * Adds a message bubble to the chat log
     * @param {string} sender - 'user' or 'ai'
     * @param {string|null} text - The message text
     * @param {boolean} isThinking - If true, shows a typing indicator
     * @returns {HTMLElement} - The created message element
     */
    function addMessageToLog(sender, text, isThinking = false) {
        const messageWrapper = document.createElement('div');
        messageWrapper.className = `chat-message ${sender}`;
        
        let contentHTML;
        if (isThinking) {
            contentHTML = `
                <div class="typing-indicator">
                    <span></span><span></span><span></span>
                </div>
            `;
        } else {
            contentHTML = `<p>${text}</p>`;
        }
        
        messageWrapper.innerHTML = `<div class="message-content">${contentHTML}</div>`;
        chatLog.appendChild(messageWrapper);
        chatLog.scrollTop = chatLog.scrollHeight; // Scroll to bottom
        return messageWrapper;
    }


    // --- Event Listeners ---
    chatInput.addEventListener('focus', () => toggleView(true));
    viewTimelineBtn.addEventListener('click', () => toggleView(false));
    sendButton.addEventListener('click', handleSendMessage);
    chatInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
            handleSendMessage();
        }
    });


    // --- Initial Call ---
    renderTimeline(initialTimelineData);
    // Remove the placeholder "thinking" message from the static HTML
    const staticThinking = document.querySelector('.chat-message.ai.thinking');
    if(staticThinking) staticThinking.remove();

});
