let users = JSON.parse(localStorage.getItem('users')) || [
    { username: 'admin', password: '', role: 'employee' },
    { username: 'guest', password: '', role: 'guest' },
];

let currentUser = null;
let selectedRoom = null;

let rooms = JSON.parse(localStorage.getItem('rooms')) || [
    { name: 'Pokój 1', status: 'Czysty', history: [] },
    { name: 'Pokój 2', status: 'Czysty', history: [] },
    { name: 'Pokój 3', status: 'Czysty', history: [] },
    { name: 'Pokój 4', status: 'Czysty', history: [] },
    { name: 'Pokój 5', status: 'Czysty', history: [] },
    { name: 'Pokój 6', status: 'Czysty', history: [] }
];

function saveRoomsToLocalStorage() {
    localStorage.setItem('rooms', JSON.stringify(rooms));
}

function showWelcome() {
    hideAllContainers();
    document.getElementById('welcomeMessage').style.display = 'block';
    document.getElementById('logoutButton').style.display = 'block';
}

function showLogin() {
    hideAllContainers();
    document.getElementById('login').style.display = 'block';
}

function login() {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    const user = users.find(u => u.username === username && u.password === password);

    if (user) {
        currentUser = username;
        if (user.role === 'employee') {
            showRoomList();
        } else {
            showWelcome();
        }
        updateUIBasedOnRole();
    } else {
        alert('Nieprawidłowa nazwa użytkownika lub hasło.');
    }
}

function showRoomList() {
    document.getElementById('login').style.display = 'none';
    document.getElementById('roomList').style.display = 'block';

    const roomList = document.getElementById('rooms');

    // czyszczenie listy pokoi przed ponownym wywołaniem
    roomList.innerHTML = '';

    rooms.forEach(room => {
        const li = document.createElement('li');

        // notatka przy pokoju tylko jeżeli status !== czysty
        const extraInfo = room.status !== 'Czysty'
            ? ` - Godzina: ${room.dueDate || 'brak'}, Notatka: ${room.note || 'brak'}`
            : '';

        li.textContent = `${room.name} - ${room.status}${extraInfo}`;
        li.onclick = () => showRoomOptions(room.name);
        roomList.appendChild(li);
    });

    hideUserList();
}

function showRoomOptions(roomName) {
    selectedRoom = roomName;
    document.getElementById('roomList').style.display = 'none';
    document.getElementById('roomOptions').style.display = 'block';

    // historia zmian statusów
    const historyList = document.getElementById('history');
    historyList.innerHTML = '';

    const room = rooms.find(r => r.name === roomName);
    if (room) {
        room.history.forEach(entry => {
            const li = document.createElement('li');
            li.textContent = entry;
            historyList.appendChild(li);
        });
    }
}

function changeStatus() {
    const statusOptions = document.getElementById('statusOptions');
    const newStatus = statusOptions.options[statusOptions.selectedIndex].text;

    // znajdowanie indeksu pokoju
    const roomIndex = rooms.findIndex(room => room.name === selectedRoom);

    if (roomIndex !== -1) {
        const room = rooms[roomIndex];

        // pobieranie info o najnowszym statusie
        const currentDate = new Date();
        const dueDate = document.getElementById('dueDate').value;
        const note = document.getElementById('note').value;

        // dodawanie wpisu do historii
        const historyEntry = `${currentDate.toLocaleString()} - ${currentUser} zmienił status na ${newStatus}, godzina do posprzątania: ${dueDate}, notatka: ${note}`;
        room.history.unshift(historyEntry);

        room.status = newStatus;
        room.dueDate = dueDate;
        room.note = note;

        // ukrywanie opcji pokoju
        document.getElementById('roomOptions').style.display = 'none';

        saveRoomsToLocalStorage();

        showRoomList();

        // alert o zmianie statusu
        showNotification(`Status pokoju ${selectedRoom} został zmieniony na: ${newStatus}`);
    } else {
        alert('Błąd: Nie można znaleźć pokoju.');
    }
}


function goBackToList() {
    // ukrywanie sekcji opcje pokoju
    document.getElementById('roomOptions').style.display = 'none';

    // powrót do listy pokoi
    showRoomList();
}

function resetApp() {
    currentUser = null;
    selectedRoom = null;
    document.getElementById('username').value = '';
    hideAllContainers();
    document.getElementById('login').style.display = 'block';
    document.getElementById('roomList').style.display = 'none';
    document.getElementById('roomOptions').style.display = 'none';
    document.getElementById('welcomeMessage').style.display = 'none';
    document.getElementById('logoutButton').style.display = 'none';

    hideUserList();
}

function showRegistration() {
    hideAllContainers();
    document.getElementById('registration').style.display = 'block';
}

function saveUsersToLocalStorage() {
    localStorage.setItem('users', JSON.stringify(users));
}

function register() {
    const newUsername = document.getElementById('newUsername').value;
    const newPassword = document.getElementById('newPassword').value;

    if (!newUsername || !newPassword) {
        alert('Proszę wypełnić wszystkie pola.');
        return;
    }

    if (users.some(user => user.username === newUsername)) {
        alert('Użytkownik o podanej nazwie już istnieje.');
        return;
    }

    users.push({ username: newUsername, password: newPassword, role: 'guest' });
    saveUsersToLocalStorage();
    alert('Rejestracja udana. Możesz się teraz zalogować.');
    showWelcome();
}

function hideAllContainers() {
    const containers = ['login', 'registration', 'welcomeMessage', 'roomList', 'roomOptions', 'userList'];

    containers.forEach(container => {
        document.getElementById(container).style.display = 'none';
    });
}

function logout() {
    resetApp();
}

function removeLastEntry() {
    const room = rooms.find(r => r.name === selectedRoom);

    if (room && room.history.length > 0) {
        room.history.shift();
        saveRoomsToLocalStorage();
        showRoomOptions(selectedRoom);
    } else {
        alert('Historia pokoju jest już pusta.');
    }
}

function clearRoomHistory() {
    const room = rooms.find(r => r.name === selectedRoom);

    if (room && room.history.length > 0) {
        room.history = [];
        saveRoomsToLocalStorage();
        showRoomOptions(selectedRoom);
    } else {
        alert('Historia pokoju jest już pusta.');
    }
}

function showUserList() {
    hideAllContainers();
    document.getElementById('userList').style.display = 'block';

    const userListContainer = document.getElementById('users');
    userListContainer.innerHTML = '';

    users.forEach(user => {
        const li = document.createElement('li');
        li.textContent = `${user.username} - Rola: ${user.role}`;

        if (user.role !== 'admin') {
            const deleteButton = document.createElement('button');
            deleteButton.textContent = 'Usuń';
            deleteButton.onclick = () => deleteUser(user.username);
            li.appendChild(deleteButton);
        }

        userListContainer.appendChild(li);
    });
}

function deleteUser(username) {
    const index = users.findIndex(user => user.username === username);

    if (index !== -1) {
        users.splice(index, 1);
        saveUsersToLocalStorage();
        showUserList();
    } else {
        alert('Błąd: Nie można znaleźć użytkownika.');
    }
}

function goBackToUserList() {
    hideAllContainers();
    showRoomList();
}

function updateUIBasedOnRole() {
    const userListButton = document.getElementById('userListButton');

    if (currentUser) {
        const user = users.find(u => u.username === currentUser);

        if (user && user.role === 'employee') {
            // wywołanie przycisku pokaż użytkowników tylko dla konta pracownika
            showUserListButton();
        } else {
            hideUserListButton();
        }
    } else {
        hideUserListButton();
    }
}

function showUserListButton() {
    const userListButton = document.getElementById('userListButton');
    userListButton.style.display = 'block';
}

function hideUserListButton() {
    const userListButton = document.getElementById('userListButton');
    userListButton.style.display = 'none';
}

function hideUserList() {
    document.getElementById('userList').style.display = 'none';
}

function removeLastEntry() {
    const room = rooms.find(r => r.name === selectedRoom);

    if (room && room.history.length > 0) {
        room.history.shift(); 
        saveRoomsToLocalStorage();
        showRoomOptions(selectedRoom);
    } else {
        alert('Historia pokoju jest już pusta.');
    }
}

function showNotification(message) {
    alert(message);
}