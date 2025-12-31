
from ytmusicapi import YTMusic

# Initialize YTMusic
ytmusic = YTMusic()
# Authenticate with headers_auth.json if available
# You can generate this file using YTMusic.setup() for authenticated requests
try:
  ytmusic = YTMusic('headers_auth.json')
except FileNotFoundError:
  print("Authentication file 'headers_auth.json' not found. Proceeding without authentication.")
def get_songs_by_artist(artist_name):
  # Search for the artist
  search_results = ytmusic.search(artist_name, filter="artists")
  if not search_results:
    print(f"No artist found with the name: {artist_name}")
    return []

  # Get the artist's details
  artist = search_results[0]
  artist_id = artist['browseId']

  # Fetch artist's songs
  artist_songs = ytmusic.get_artist(artist_id)
  if 'songs' in artist_songs and 'results' in artist_songs['songs']:
    songs = artist_songs['songs']['results']
    return [song['title'] for song in songs]
  else:
    print(f"No songs found for the artist: {artist_name}")
    return []

# Example usage
artist_name = "Adele"  # Replace with the desired artist's name
songs = get_songs_by_artist(artist_name)
print(f"Songs by {artist_name}:")
for song in songs:
  print(song)
