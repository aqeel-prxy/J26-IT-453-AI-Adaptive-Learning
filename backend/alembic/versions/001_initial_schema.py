"""Initial database schema migration for J26-IT-453

Revision ID: 001_initial_schema
Revises: 
Create Date: 2026-10-03 15:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '001_initial_schema'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # 1. students
    op.create_table(
        'students',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('anonymized_student_code', sa.String(64), unique=True, nullable=False),
        sa.Column('email', sa.String(255), unique=True, nullable=False),
        sa.Column('hashed_password', sa.String(255), nullable=False),
        sa.Column('grade_level', sa.Integer(), nullable=False, server_default='10'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False)
    )
    op.create_index('ix_students_email', 'students', ['email'])
    op.create_index('ix_students_anonymized_code', 'students', ['anonymized_student_code'])

    # 2. concepts
    op.create_table(
        'concepts',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('topic_category', sa.String(100), nullable=False),
        sa.Column('code', sa.String(50), unique=True, nullable=False),
        sa.Column('title', sa.String(255), nullable=False),
        sa.Column('prerequisite_concept_ids', sa.JSON(), nullable=False),
        sa.Column('grade_level', sa.Integer(), nullable=False, server_default='10')
    )
    op.create_index('ix_concepts_code', 'concepts', ['code'])
    op.create_index('ix_concepts_topic', 'concepts', ['topic_category'])

    # 3. questions
    op.create_table(
        'questions',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('concept_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('concepts.id'), nullable=False),
        sa.Column('difficulty_level', sa.Float(), nullable=False, server_default='0.5'),
        sa.Column('question_text', sa.Text(), nullable=False),
        sa.Column('reference_solution', sa.JSON(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False)
    )
    op.create_index('ix_questions_concept_id', 'questions', ['concept_id'])

    # 4. attempts
    op.create_table(
        'attempts',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('student_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('students.id'), nullable=False),
        sa.Column('question_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('questions.id'), nullable=False),
        sa.Column('is_correct', sa.Boolean(), nullable=False),
        sa.Column('student_solution', sa.Text(), nullable=False),
        sa.Column('response_time_ms', sa.Integer(), nullable=False),
        sa.Column('attempt_number', sa.Integer(), nullable=False, server_default='1'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False)
    )
    op.create_index('ix_attempts_student_id', 'attempts', ['student_id'])
    op.create_index('ix_attempts_question_id', 'attempts', ['question_id'])

    # 5. learner_profiles
    op.create_table(
        'learner_profiles',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('student_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('students.id'), nullable=False),
        sa.Column('concept_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('concepts.id'), nullable=False),
        sa.Column('mastery_probability', sa.Float(), nullable=False, server_default='0.1'),
        sa.Column('forgetting_factor', sa.Float(), nullable=False, server_default='1.0'),
        sa.Column('last_practiced_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True)
    )

    # 6. error_diagnosis
    op.create_table(
        'error_diagnosis',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('attempt_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('attempts.id'), nullable=False),
        sa.Column('student_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('students.id'), nullable=False),
        sa.Column('question_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('questions.id'), nullable=False),
        sa.Column('failed_step_index', sa.Integer(), nullable=True),
        sa.Column('error_category', sa.String(50), nullable=False),
        sa.Column('explanation_text', sa.Text(), nullable=False),
        sa.Column('corrected_step', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False)
    )

    # 7. representations
    op.create_table(
        'representations',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('concept_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('concepts.id'), nullable=False),
        sa.Column('format_type', sa.String(50), nullable=False),
        sa.Column('content_payload', sa.JSON(), nullable=False),
        sa.Column('complexity_level', sa.Float(), nullable=False, server_default='0.5')
    )

    # 8. representation_outcomes
    op.create_table(
        'representation_outcomes',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('student_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('students.id'), nullable=False),
        sa.Column('representation_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('representations.id'), nullable=False),
        sa.Column('duration_seconds', sa.Integer(), nullable=False),
        sa.Column('is_successful', sa.Boolean(), nullable=False),
        sa.Column('switched_from_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('representations.id'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False)
    )

    # 9. student_engagement
    op.create_table(
        'student_engagement',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('student_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('students.id'), unique=True, nullable=False),
        sa.Column('current_streak_days', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('total_points', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('virtual_pet_health', sa.Integer(), nullable=False, server_default='100'),
        sa.Column('virtual_pet_level', sa.Integer(), nullable=False, server_default='1'),
        sa.Column('last_activity_date', sa.Date(), nullable=True),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=True)
    )

    # 10. game_sessions
    op.create_table(
        'game_sessions',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('student_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('students.id'), nullable=False),
        sa.Column('game_type', sa.String(50), nullable=False),
        sa.Column('score', sa.Integer(), nullable=False),
        sa.Column('accuracy', sa.Float(), nullable=False),
        sa.Column('duration_seconds', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False)
    )


def downgrade():
    op.drop_table('game_sessions')
    op.drop_table('student_engagement')
    op.drop_table('representation_outcomes')
    op.drop_table('representations')
    op.drop_table('error_diagnosis')
    op.drop_table('learner_profiles')
    op.drop_table('attempts')
    op.drop_table('questions')
    op.drop_table('concepts')
    op.drop_table('students')
