from fastapi import APIRouter, HTTPException, Depends
import httpx
from pydantic import BaseModel

router = APIRouter()

class UserCreate(BaseModel):
    username: str
    email: str
    password: str

@router.post("/")
async def create_user(user: UserCreate):
    """
    Crea un nuevo usuario utilizando el servidor ATProto
    """
    try:
        # Llamada al servicio ATProto
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "http://localhost:3000/xrpc/com.atproto.server.createAccount",
                json={
                    "email": user.email,
                    "password": user.password,
                    "handle": user.username
                }
            )
            
            if response.status_code != 200:
                raise HTTPException(status_code=response.status_code, detail=response.json())
                
            return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))