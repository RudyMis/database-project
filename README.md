# Projekt

## Opis

Program ma następujące funkcje:

* Wyświetla aktualny plan zapotrzebowania z opcjami wyboru grupy produktów i kraju
* Pokazuje wykres porównujący budżet, produkcję i plan
* Umożliwia edycję planu dla poszczegółnych produktów
* Informuje użytkownika, gdy plan zakłada sprzedaż wyższą od produkcji

## Wymagania

Do uruchomienia potrzebne są następujące programy:

* [Docker](docker.com)
* [docker-compose](https://github.com/docker/compose)

Polecenie instalowania na Archu:
```
sudo pacman -S docker docker-compose
```

Można też skonfugurować dockera, żeby nie trzeba było go uruchamiać za pomocą `sudo` [link](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

## Kompilacja

Albo uruchomić skrypt `setup.sh` (skrypt wymaga `docker buildx` który ładnie wypisuje i nie wiem czy przychodzi w pakiecie z dockerem), który zbuduje obrazy kontenerów i je odpali, albo manualnie:

```
docker build -t bdp-backend backend
docker build -t bdp-frontend frontend

docker-compose up -d
```

Po tym powinny zostać utworzone trzy kontenery

## Korzystanie

Frontend powinien się pojawić na stronie [http://localhost:3000](http://localhost:3000) a backend na [http://localhost::9090](http://localhost::9090)
