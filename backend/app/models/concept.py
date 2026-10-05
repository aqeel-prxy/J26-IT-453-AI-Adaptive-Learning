import uuid
from sqlalchemy import Column, String, Integer, JSON, Uuid
from app.database.base import Base


class Concept(Base):
    __tablename__ = "concepts"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    topic_category = Column(String(100), nullable=False, index=True)
    code = Column(String(50), unique=True, nullable=False, index=True)
    title = Column(String(255), nullable=False)
    prerequisite_concept_ids = Column(JSON, default=list, nullable=False)
    grade_level = Column(Integer, nullable=False, default=10)
