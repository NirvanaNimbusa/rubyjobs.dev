# frozen_string_literal: true

RSpec.describe Web::Controllers::Companies::Show, type: :action do
  subject { action.call(params) }

  let(:action) { described_class.new(operation: operation, review_operation: review_operation) }

  let(:params) { { id: 0 } }

  context 'when operation returns success value' do
    let(:operation) { ->(*) { Success(Company.new(id: 0)) } }
    let(:review_operation) { ->(*) { Success([Review.new]) } }

    it { expect(subject).to be_success }

    it 'call operation with a right contract' do
      expect(operation).to receive(:call).with(id: 0)
      subject
    end

    it 'exposes vacancy' do
      subject
      expect(action.company).to eq(Company.new(id: 0))
      expect(action.reviews).to eq([Review.new])
    end
  end

  context 'when operation returns failure value' do
    let(:operation) { ->(*) { Failure(:not_found) } }
    let(:review_operation) { ->(*) { Success([Review.new]) } }

    it { expect(subject).to redirect_to '/companies' }

    it 'call operation with a right contract' do
      expect(operation).to receive(:call).with(id: 0)
      subject
    end
  end

  context 'with real dependencies' do
    subject { action.call(params) }

    let(:action) { described_class.new }
    let(:params) { { id: company.id } }

    let(:company) { Fabricate.create(:company) }

    before { Fabricate(:review, company_id: company.id) }

    it { expect(subject).to be_success }
  end
end
