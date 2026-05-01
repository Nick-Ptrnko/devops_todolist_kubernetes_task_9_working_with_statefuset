#!/bin/bash

# Кольори для виводу
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}--- Запуск розгортання інфраструктури ---${NC}"

# 1. Створення кластера Kind
if kind get clusters | grep -q "^kind$"; then
    echo -e "${BLUE}Кластер Kind вже існує. Пропускаю створення.${NC}"
else
    echo -e "${GREEN}Створення кластера Kind за допомогою cluster.yml...${NC}"
    kind create cluster --config cluster.yml
fi

echo -e "${GREEN}Створення Namespaces...${NC}"
kubectl apply -f .infrastructure/namespace.yml
kubectl apply -f .infrastructure/mysql-namespace.yml

echo -e "${GREEN}Налаштування сховища (PV та PVC)...${NC}"
kubectl apply -f .infrastructure/pv.yml
kubectl apply -f .infrastructure/pvc.yml

echo -e "${GREEN}Розгортання MySQL (Secrets, ConfigMaps, Service, StatefulSet)...${NC}"
kubectl apply -f .infrastructure/mysql-secret.yml
kubectl apply -f .infrastructure/mysql-init-config.yml
kubectl apply -f .infrastructure/mysql-service.yml
kubectl apply -f .infrastructure/mysql-statefulset.yml

echo -e "${BLUE}Очікування запуску MySQL (це може зайняти хвилину)...${NC}"
kubectl wait --for=condition=ready pod -l app=mysql -n mysql --timeout=120s

echo -e "${GREEN}Налаштування додатку (Secrets, ConfigMaps)...${NC}"
kubectl apply -f .infrastructure/secret.yml
kubectl apply -f .infrastructure/app-db-secret.yml
kubectl apply -f .infrastructure/confgiMap.yml
kubectl apply -f .infrastructure/app-settings-patch.yml

echo -e "${GREEN}Розгортання додатку (Deployment та Service)...${NC}"
kubectl apply -f .infrastructure/deployment.yml
kubectl apply -f .infrastructure/nodeport.yml

echo -e "${BLUE}Очікування готовності додатку...${NC}"
kubectl wait --for=condition=available deployment/todoapp -n todoapp --timeout=60s

echo -e "${GREEN}--- Розгортання завершено успішно! ---${NC}"
echo -e "Додаток доступний за адресою: http://localhost:30007"
