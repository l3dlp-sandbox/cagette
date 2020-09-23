import { ActivateDistribSlotsViewProps } from './views/ActivateDistribSlotsView/ActivateDistribSlotsView';
import { UserDistribSlotsSelectorViewProps } from './views/UserDistribSlotsSelectorView';
import { DistribSlotsResolverProps } from './views/DistribSlotsResolver';
import { PlaceDialogViewProps } from './views/PlaceDialogView';
import { PlaceViewProps } from './views/PlaceView';
import { MangopayConfigProps } from '../modules/Mangopay/MangopayConfig';
import { MessagesProps } from '../modules/Messages/containers/MessagingService';
export default class NeolithicViewsGenerator {
    static setApiUrl(url: string): void;
    static setGraphUrl(url: string): void;
    static activateDistribSlots(elementId: string, props: ActivateDistribSlotsViewProps): void;
    static userDistribSlotsSelector(elementId: string, props: UserDistribSlotsSelectorViewProps): void;
    static distribSlotsResolver(elementId: string, props: DistribSlotsResolverProps): void;
    static placeDialog(elementId: string, props: Omit<PlaceDialogViewProps, 'onClose'>): void;
    static place(elementId: string, props: PlaceViewProps): void;
    static mangopayModule(elementId: string, props: MangopayConfigProps): void;
    static messagesModule(elementId: string, props: MessagesProps): void;
    static messageModule(elementId: string): void;
}
