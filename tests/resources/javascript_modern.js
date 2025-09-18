// Modern JavaScript with ES6+ features
class EventEmitter {
    constructor() {
        this.events = new Map();
    }

    on(event, callback) {
        if (!this.events.has(event)) {
            this.events.set(event, []);
        }
        this.events.get(event).push(callback);
    }

    emit(event, ...args) {
        const callbacks = this.events.get(event);
        if (callbacks) {
            callbacks.forEach(callback => callback(...args));
        }
    }
}

// Async/await with arrow functions
const fetchUserData = async (userId) => {
    try {
        const response = await fetch(`/api/users/${userId}`);
        const data = await response.json();

        return {
            ...data,
            timestamp: Date.now(),
            fullName: `${data.firstName} ${data.lastName}`
        };
    } catch (error) {
        console.error('Failed to fetch user:', error);
        throw new Error(`User ${userId} not found`);
    }
};

// Destructuring and template literals
const processUsers = async (userIds) => {
    const users = await Promise.all(
        userIds.map(id => fetchUserData(id))
    );

    return users
        .filter(({ age }) => age >= 18)
        .map(user => ({
            id: user.id,
            displayName: user.fullName.toUpperCase(),
            isActive: user.lastLogin > Date.now() - 86400000
        }));
};

export { EventEmitter, fetchUserData, processUsers };