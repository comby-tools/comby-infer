all:
	npx elm-live src/Main.elm --no-server -- --output=../server/public/dist/main.js

dev:
	elm make src/Main.elm --output=../server/public/dist/main.js

standalone:
	npx elm-live src/Main.elm --start-page=index.html -- --output=public/dist/main.js

release:
	@elm make src/Main.elm --optimize --output=/tmp/main.js
	@uglifyjs /tmp/main.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output ../server/public/dist/main.js

clean:
	@rm -r elm-stuff	

.PHONY: all dev standalone release clean
