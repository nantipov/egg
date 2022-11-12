BUILD_DOCKER = docker run -v "$(CURDIR)"\:/build --workdir /build --user $(id -u):$(id -g) nantipov/egg-build:latest

MPY = mpy-cross
CARGO = cargo
DOCKER = docker
YARN = yarn
OPENSCAD = openscad

.PHONY: client server web

clean:
	@echo ">>> Clean"
	rm -f -r client/build

client:
	@echo ">>> Build client"
	mkdir -p client/build
	$(MPY) client/main.py -o client/build/main.mpy
	$(MPY) client/core.py -o client/build/core.mpy

server:
	@echo ">>> Build serer"
	cd server; $(CARGO) build --release

web:
	@echo ">>> Build web"
	cd web; $(YARN) install

3d-models:
	@echo ">>> Build 3D models"
	$(OPENSCAD) -o hardware/body-model/egg_bottom.stl -D 'release=true' -D 'target="bottom"' hardware/body-model/egg.scad
	$(OPENSCAD) -o hardware/body-model/egg_middle.stl -D 'release=true' -D 'target="middle"' hardware/body-model/egg.scad
	$(OPENSCAD) -o hardware/body-model/egg_top.stl -D 'release=true' -D 'target="top"' hardware/body-model/egg.scad
	$(OPENSCAD) -o hardware/body-model/egg_rack.stl -D 'release=true' -D 'target="rack"' hardware/body-model/egg.scad
	$(OPENSCAD) -o docresources/egg-3d-model1.png -D 'target="composition"' \
	            --camera '-18.91,-2.58,-0.98,90.70,0.00,202.80,292.71' \
				--projection perspective \
				--autocenter hardware/body-model/egg.scad
	$(OPENSCAD) -o docresources/egg-3d-model2.png -D 'target="composition"' \
	            --camera '-18.91,-2.58,-0.98,49.40,0.00,213.30,292.71' \
				--projection perspective \
				--autocenter hardware/body-model/egg.scad
	$(OPENSCAD) -o docresources/egg-3d-model3.png -D 'target="composition"' \
	            --camera '0,0,0,113.80,0.00,203.50,425.04' \
				--projection perspective \
				--autocenter hardware/body-model/egg.scad
	$(OPENSCAD) -o docresources/egg-3d-model4.png -D 'target="composition2"' \
	            --camera '-4.42,-31.79,-4.02,71.80,0.00,258.40,278.87' \
				--projection perspective \
				--autocenter hardware/body-model/egg.scad

docker-image-server:
	@echo ">>> Build server docker image"
	cd server; $(DOCKER) build .

docker-image-web:
	@echo ">>> Build web docker image"
	cd web; $(DOCKER) build .

client-in-docker:
	@echo ">>> Build client in docker"
	$(BUILD_DOCKER) make client

server-in-docker:
	@echo ">>> Build server in docker"
	$(BUILD_DOCKER) make server

web-in-docker:
	@echo ">>> Build web in docker"
	$(BUILD_DOCKER) make web

3d-models-in-docker:
	@echo ">>> Build 3D-models in docker"
	$(BUILD_DOCKER) make 3d-models


code: clean client server web docker-image-server docker-image-web

code-in-docker: clean client-in-docker server-in-docker web-in-docker docker-image-server docker-image-web
