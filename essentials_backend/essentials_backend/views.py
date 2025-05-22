from django.http import HttpResponse

def api_index(request):
    return HttpResponse("""
        <h2>Essentials USTP API Index</h2>
        <ul>
            <li><a href='/admin/'>Django Admin</a></li>
            <li><a href='/api/auth/'>Auth API</a></li>
            <li><a href='/api/products/'>Products API</a></li>
            <li><a href='/api/orders/'>Orders API</a></li>
            <li><a href='/api/pickup-locations/'>Pickup Locations API</a></li>
        </ul>
    """) 