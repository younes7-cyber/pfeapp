require("dotenv").config(); // Charge les variables d'environnement

const express = require("express");
const { MongoClient } = require("mongodb");

const app = express();
const PORT = process.env.PORT || 3000; // Utilise le port défini par Render

// Middleware pour parser le JSON
app.use(express.json());

// 🔹 Connexion à MongoDB
const uri = process.env.MONGO_URI; // Récupère l'URI MongoDB depuis Render

if (!uri) {
    console.error(" MongoDB connection string is undefined.");
    process.exit(1);
}

const client = new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

// Connexion à MongoDB et récupération de la base de données
async function connectDB() {
    try {
        await client.connect();
        console.log(" Connexion à MongoDB réussie !");
    } catch (err) {
        console.error(" Erreur de connexion à MongoDB :", err);
    }
}
connectDB();

const db = client.db("testDB"); // Remplace "testDB" par le nom de ta base
const collection = db.collection("messages"); // Collection MongoDB

// 🔹 Route d'accueil (Test)
app.get("/", (req, res) => {
    res.send(" API MongoDB en ligne !");
});

// 🔹 Route pour récupérer tous les messages
app.get("/messages", async (req, res) => {
    try {
        const messages = await collection.find().toArray();
        res.json(messages);
    } catch (error) {
        res.status(500).json({ error: "Erreur lors de la récupération des messages" });
    }
});

// 🔹 Route pour ajouter un message
app.post("/messages", async (req, res) => {
    try {
        const { message } = req.body;
        if (!message) {
            return res.status(400).json({ error: "Message requis" });
        }
        const newMessage = { message, createdAt: new Date() };
        await collection.insertOne(newMessage);
        res.json({ message: "Message ajouté avec succès", data: newMessage });
    } catch (error) {
        res.status(500).json({ error: "Erreur lors de l'ajout du message" });
    }
});

// 🔹 Lancer le serveur
app.listen(PORT, () => {
    console.log(` Serveur en ligne sur le port ${PORT}`);
});
