const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Oda durumunu tutan basit nesne
// rooms[roomId] = [socketId1, socketId2]
const rooms = {};

io.on('connection', (socket) => {
  console.log(`User connected: ${socket.id}`);

  // Oda Oluştur
  socket.on('create-room', (callback) => {
    // 6 haneli rastgele kod üret
    const roomId = Math.floor(100000 + Math.random() * 900000).toString();
    rooms[roomId] = [socket.id];
    socket.join(roomId);
    console.log(`Room created: ${roomId} by ${socket.id}`);
    if (typeof callback === 'function') {
      callback({ success: true, roomId });
    }
  });

  // Odaya Katıl
  socket.on('join-room', (roomId, callback) => {
    if (rooms[roomId]) {
      if (rooms[roomId].length >= 2) {
        if (typeof callback === 'function') callback({ success: false, message: 'Oda dolu!' });
        return;
      }
      rooms[roomId].push(socket.id);
      socket.join(roomId);
      console.log(`User ${socket.id} joined room: ${roomId}`);
      
      if (typeof callback === 'function') {
        callback({ success: true, roomId });
      }
      
      socket.to(roomId).emit('user-joined', socket.id);
    } else {
      if (typeof callback === 'function') callback({ success: false, message: 'Oda bulunamadı!' });
    }
  });

  // Otomatik Eşleşme (Anında Görüşme)
  socket.on('auto-match', (callback) => {
    let joinedRoom = null;
    // Bekleyen 1 kişilik oda bul
    for (const roomId in rooms) {
      if (rooms[roomId].length === 1) {
        joinedRoom = roomId;
        break;
      }
    }

    if (joinedRoom) {
      // Odaya katıl
      rooms[joinedRoom].push(socket.id);
      socket.join(joinedRoom);
      console.log(`User ${socket.id} auto-joined room: ${joinedRoom}`);
      if (typeof callback === 'function') callback({ success: true, roomId: joinedRoom, isCreator: false });
      socket.to(joinedRoom).emit('user-joined', socket.id);
    } else {
      // Yeni oda kur
      const newRoomId = Math.floor(100000 + Math.random() * 900000).toString();
      rooms[newRoomId] = [socket.id];
      socket.join(newRoomId);
      console.log(`User ${socket.id} auto-created room: ${newRoomId}`);
      if (typeof callback === 'function') callback({ success: true, roomId: newRoomId, isCreator: true });
    }
  });

  // WebRTC - Offer Gönderimi
  socket.on('webrtc-offer', (data) => {
    const { roomId, offer } = data;
    console.log(`Offer sent to room: ${roomId}`);
    socket.to(roomId).emit('webrtc-offer', offer);
  });

  // WebRTC - Answer Gönderimi
  socket.on('webrtc-answer', (data) => {
    const { roomId, answer } = data;
    console.log(`Answer sent to room: ${roomId}`);
    socket.to(roomId).emit('webrtc-answer', answer);
  });

  // WebRTC - ICE Candidate Gönderimi
  socket.on('webrtc-ice-candidate', (data) => {
    const { roomId, candidate } = data;
    console.log(`ICE Candidate sent to room: ${roomId}`);
    socket.to(roomId).emit('webrtc-ice-candidate', candidate);
  });

  // Metin / Sesli / İşaret Dili Verisi Gönderimi
  socket.on('app-message', (data) => {
    const { roomId, type, content } = data;
    console.log(`App Message (${type}) sent to room: ${roomId} -> ${content}`);
    socket.to(roomId).emit('app-message', { type, content, senderId: socket.id });
  });

  // Kullanıcı ayrıldığında
  socket.on('disconnect', () => {
    console.log(`User disconnected: ${socket.id}`);
    // Kullanıcının bulunduğu odalardan onu sil
    for (const roomId in rooms) {
      if (rooms[roomId].includes(socket.id)) {
        rooms[roomId] = rooms[roomId].filter(id => id !== socket.id);
        socket.to(roomId).emit('user-disconnected', socket.id);
        // Oda boşaldıysa sil
        if (rooms[roomId].length === 0) {
          delete rooms[roomId];
        }
      }
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Signaling Server is running on port ${PORT}`);
});
