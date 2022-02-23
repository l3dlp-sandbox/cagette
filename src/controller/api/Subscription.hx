package controller.api;
import service.SubscriptionService;
import haxe.Json;
import neko.Web;
import tink.core.Error;

typedef NewSubscriptionDto = {
    userId:Int,
    catalogId:Int,
    distributions:Array<{id:Int,orders:Array<{id:Int,productId:Int,qty:Float}>}>,
    absentDistribsIds:Array<Int>
};

class Subscription extends Controller
{

	public function doDefault(sub:db.Subscription){

        // Create a new sub
        var post = StringTools.urlDecode( sugoi.Web.getPostData() );
        if(post!=null && sub==null){
            var newSubData : NewSubscriptionDto = Json.parse(post);
            var user = db.User.manager.get(newSubData.userId,false);
            var catalog = db.Catalog.manager.get(newSubData.catalogId,false);

            if(!app.user.isAdmin() && !user.canManageContract(catalog) && app.user.id!=user.id){
                throw new Error(403,"You're not allowed to create a subscription for this user");
            }

            var ss = new SubscriptionService();
            var ordersData = newSubData.distributions[0].orders.map( o -> {productId:o.productId, quantity:o.qty,userId2:null,invertSharedOrder:null});
            sub = ss.createSubscription(user,catalog,ordersData);
            if(newSubData.absentDistribsIds!=null){
                sub.setAbsences(newSubData.absentDistribsIds);
                sub.update();
            }
        }    

        return json({
            startDate : sub.startDate,
            endDate : sub.endDate,
            user : sub.user.infos(),
            user2 : sub.user2==null ? null : sub.user2.infos(),
            catalogId : sub.catalog.id
        });

    }

}