require("dotenv").config(); // Charge les variables d'environnement

const { MongoClient } = require('mongodb');

const uri = process.env.MONGO_URI; // Récupère l'URI depuis Render

if (!uri) {
    console.error("MongoDB connection string is undefined.");
    process.exit(1);
}

const client = new MongoClient(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

async function run() {
    try {
        await client.connect();
        console.log(" Connexion à MongoDB réussie !");
    } catch (err) {
        console.error(" Erreur de connexion à MongoDB :", err);
    }
}

run();

module.exports = client;
