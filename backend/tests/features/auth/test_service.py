import pytest
from datetime import datetime, timezone

from app.features.auth.service import (
    create_user_account,
    delete_user_account,
    _get_user_account_by_uid,
    _get_user_account_by_email
)
from app.features.auth.schemas import UserCreate, UserResponse
from app.features.auth.exceptions import (
    UserAlreadyExistsException,
    UserDoesNotExistsException
)
from app.models.user import User


class TestCreateUserAccount:
    """Tests create_user_account function"""

    def test_create_user_account_success(self, db_session, sample_user_data):

        user_credential = UserCreate(**sample_user_data)

        result = create_user_account(db_session, user_credential)
        
        # Assert
        assert result.uid == sample_user_data["uid"]
        assert result.email == sample_user_data["email"]
        assert result.setup_completed is False
        assert result.created_at is not None
        assert result.last_modified_at is not None
        
        # Check if user is in the database
        db_user = db_session.query(User).filter(User.uid == sample_user_data["uid"]).first()
        assert db_user is not None
        assert db_user.email == sample_user_data["email"]

    def test_create_user_account_duplicate_uid(self, db_session, sample_user_data):

        # Arrange - Create first user
        user_credential = UserCreate(**sample_user_data)
        create_user_account(db_session, user_credential)
        
        # Act & Assert - Try to create another user with same id
        with pytest.raises(UserAlreadyExistsException) as exc_info:
            create_user_account(db_session, user_credential)
        
        assert str(exc_info.value) == "User already exists"
    
    def test_create_user_account_duplicate_email(self, db_session, sample_user_data):

        # Arrange - Create first user
        user_credential_1 = UserCreate(**sample_user_data)
        create_user_account(db_session, user_credential_1)
        
        # Act & Assert - Try to create another user with different uid but same email
        user_credential_2 = UserCreate(
            uid="different_uid_67890",
            email=sample_user_data["email"]
        )
        
        with pytest.raises(UserAlreadyExistsException):
            create_user_account(db_session, user_credential_2)
    
    def test_create_user_account_timestamps(self, db_session, sample_user_data):
        # Arrange
        user_credential = UserCreate(**sample_user_data)
        before_creation = datetime.now()
        
        # Act
        result = create_user_account(db_session, user_credential)
        after_creation = datetime.now()
        
        # Assert
        assert before_creation <= result.created_at <= after_creation
        assert before_creation <= result.last_modified_at <= after_creation


class TestDeleteUserAccount:
    pass


class TestPrivateHelperFunctions:
    pass


class TestEdgeCases:
    
    def test_create_user_with_empty_email(self, db_session):

        with pytest.raises(Exception):
            UserCreate(uid="test_uid", email="")
    

    @pytest.mark.parametrize("email", [
        "valid@example.com",
        "user+tag@example.co.uk",
        "test.user@subdomain.example.com"
    ])
    def test_create_user_with_various_email_formats(self, db_session, email):
        # Arrange
        user_credential = UserCreate(uid=f"uid_{email}", email=email)
        
        # Act
        result = create_user_account(db_session, user_credential)
        
        # Assert
        assert result.email == email