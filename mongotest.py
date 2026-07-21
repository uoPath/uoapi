from pymongo import MongoClient
from datetime import datetime, timezone
import json, sys, os

mongo_url = os.getenv("MONGO_URL", "mongodb://db:27017")
client = MongoClient(mongo_url)
db = client["course"]

try:
    client.db.command('ping')
except Exception as e:
    print(e)
    sys.exit(1)
    
file = sys.argv[1]

data = json.load(sys.stdin)

subject = data["courses"]["subject_code"]
courses = data["courses"]["courses"]

for c in courses:
    doc = {
        "CourseCode": f"{subject} {c['course_code']}",
        "Subject": subject,
        "Code": c["course_code"],
        "Title": c.get("title", ""),
        "Credits": c.get("credits", 0),
        "Description": c.get("description", ""),
        "Components": ", ".join(c.get("components", [])),
        "PrerequisitesText": c.get("prerequisites", ""),
        "DependenciesString": c.get("dependencies", ""),
        "Dependencies": None,
        "ModifiedTime": datetime.now(timezone.utc),
        "AvailableSeason": 7
    }
    
    db.course_details.update_one(
        {
            "Subject": subject,
            "Code": c["course_code"]
        },
        {"$set": doc},
        upsert=True
    )
    