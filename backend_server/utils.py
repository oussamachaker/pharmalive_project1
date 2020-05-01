from geopy.geocoders import Nominatim

def geocoding(address: str) -> dict:
    """
    Utility function used to convert physical address to latitude/longitude location
    """
    locator = Nominatim(user_agent="myGeocoder")
    location = locator.geocode(address)
    return (location.latitude, location.longitude)