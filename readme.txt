booth data url:
https://torvid21.github.io/secret_test_omna/furality/booth_data.json
PC booth images:
https://torvid21.github.io/secret_test_omna/furality/Booth/Booth_*.png
Mobile booth images:
https://torvid21.github.io/secret_test_omna/furality/Booth_mobile/Booth_*.png

booth images are 2048x2408
mobile booth images are 512x512


gallery data url:
https://torvid21.github.io/secret_test_omna/furality/gallery_data.json
Art gallery images:
https://torvid21.github.io/secret_test_omna/furality/ArtGallery/art_*.png

gallery images are resized to have a *max* dimension of 2048
mobile gallery images are resied to have a *max* dimension of 512



9 pavillions
ID order:
[100, 200, 300], [400, 500, 600], [700, 800, 900]

32 + 4 booths per pavillion

after 31 it skips to 50, 51, 52, 53 for the special booths

json

"videoUrl": either mp4 or png for the back wall
"imageUrl": png for the rest of the booth
"id": booth ID
"avm": secret data?
"island": island name, valid names: "Avatar Bases", "Avatar Assets", "Avatar Services", "2D Illustration", "Other"
"name": name
"imageUrl": url to the main booth image
"videoUrl": url to the back wall image or video
"category": list of categories. valid categories: "Anthro Character Art", "Avatar Assets", "Avatar Bases", "3D Modeling", "3D Rendered Art", "Avatar Modeling", "Avatar Retextures", "Comics/Books", "Digital Art", "Fursuits", "Merchandise", "Merchandise Creation",, "Musician", "Traditional Art", "Twitch Production", "Video Production", "World Creation", "Other"
"webUrl": link to furality thing
"avatars": list of avatar IDs


