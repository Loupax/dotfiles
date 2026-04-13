update:
	git submodule update --remote --merge
	git add -A
	git diff --cached --quiet || git commit -m "Update submodule refs"
	git push
