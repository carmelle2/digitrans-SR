FROM node:18-alpine

WORKDIR /app

# Installation des dépendances
COPY package*.json ./
RUN npm install

# Copie du code source et compilation des smart contracts
COPY . .
RUN npx hardhat compile

# Exposition du port RPC de la blockchain
EXPOSE 8545

# Démarrage d'un nœud Hardhat local (Private Network) accessible de l'extérieur
CMD ["npx", "hardhat", "node", "--hostname", "0.0.0.0"]
