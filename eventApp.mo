
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Trie "mo:base/Trie";
import Option "mo:base/Option";

//ContactApp

actor {
   type ContactId = Nat32;

   type Contact = {
     name: Text;
     phone: Text;
     email: Text;
     isFavorite: Bool;
     isBlocked: Bool;
   };

   type ResponseContact = {
     name: Text;
     phone: Text;
     email: Text;
     isFavorite: Bool;
     isBlocked: Bool;
     id: Nat32;
   };


   private stable var next :ContactId = 0;

//tabloyu kontrol eden değişken ıd ye göre veri ekleyip silmeye yarar
   private stable var contacts : Trie.Trie<ContactId, Contact> = Trie.empty();



 

   public func addContact(contact: Contact) : async Text {

    if ( not validatePhoneNumber(contact.phone) ) { 
      return ("Phone number must be 10 digit")
    };

     let contactId = next; 
     next +=1;

     contacts := Trie.replace(
       contacts,
       key(contactId),
       Nat32.equal,
?contact,
     ).0; 
     return ("Contact is created successfully")
   };


   public func getContacts () : async [(ResponseContact)]  {
    return Trie.toArray<ContactId, Contact, ResponseContact>(
    contacts,
    func (k, v) : (ResponseContact) {
      {id= k; name = v.name; phone = v.phone; email= v.email; isFavorite= v.isFavorite; isBlocked= v.isBlocked}
    }
  );
  };


   public func updateContact(contactId:ContactId,contact: Contact) : async Bool{
    let result = Trie.find(contacts, key(contactId), Nat32.equal);
    let exists = Option.isSome(result);
    if(exists) {
      contacts := Trie.replace(
        contacts,
      key(contactId),
      Nat32.equal,
      ?contact,).0
      };
      return exists;
   };

public func deleteContact(contactId:ContactId) : async Bool {
    let result = Trie.find(contacts, key(contactId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {
      contacts := Trie.replace(
        contacts,
        key(contactId),
        Nat32.equal,
        null,
      ).0;
    };
    return exists;
  };

    private func validatePhoneNumber (phone:Text): Bool {
    if (phone.size() != 10) {
      return false;
    };
    return true;
  };
//idimizi yönetmemizi ve hash adı altında ilgili tablomuza eklmemizi sağlar
  private func key(x:ContactId) : Trie.Key<ContactId> {
     return {hash= x; key = x};
   };

};
